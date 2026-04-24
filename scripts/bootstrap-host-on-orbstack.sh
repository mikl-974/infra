#!/usr/bin/env bash
# bootstrap-host-on-orbstack.sh — Promotes an existing OrbStack VM to a
# host defined in this repo (default: `homelab`).
#
# Steps performed against the remote VM (over SSH):
#   1. Push the local mfo Age private key to /var/lib/sops-nix/key.txt
#      so that sops-nix can decrypt the host's secrets at activation.
#   2. Generate the SSH host keys (`ssh-keygen -A`) needed by sops-nix
#      (it derives an age recipient from the ed25519 host key).
#   3. Append mfo's pubkey to the SSH login user's authorized_keys so the
#      operator keeps shell access during/after the first `nixos-rebuild`.
#   4. Install /etc/nixos/orbstack-bridge.nix and patch
#      /etc/nixos/configuration.nix so the OrbStack lxc baseline that gets
#      rebuilt on every boot pulls in a oneshot service that re-runs
#      `nixos-rebuild switch --impure --flake /etc/infra#<host>`. This
#      defeats OrbStack's per-boot reset of /nix/var/nix/profiles/system.
#
# After this script, run from the VM:
#   cd /etc/infra && sudo nix --extra-experimental-features 'nix-command flakes' \
#     run /etc/infra#install-manual -- <host>

set -euo pipefail
# (legacy header; canonical doc above)


_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./lib/workstation-install.sh
source "$_SCRIPT_DIR/lib/workstation-install.sh"
# shellcheck source=./lib/install-target.sh
source "$_SCRIPT_DIR/lib/install-target.sh"
REPO_ROOT="$(resolve_repo_root "$_SCRIPT_DIR")"

SSH_TARGET="mickael@orb"
AGE_KEY_OVERRIDE=""
HOST="homelab"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ssh-target) SSH_TARGET="$2"; shift 2 ;;
    --age-key)    AGE_KEY_OVERRIDE="$2"; shift 2 ;;
    --host)       HOST="$2"; shift 2 ;;
    -h|--help)
      sed -n '2,18p' "$0"; exit 0 ;;
    *) die "Argument inconnu : $1" ;;
  esac
done

KEYS_NIX="$REPO_ROOT/modules/users/authorized-keys.nix"
SOPS_YAML="$REPO_ROOT/.sops.yaml"

AGE_KEY="${AGE_KEY_OVERRIDE:-}"
[[ -z "$AGE_KEY" && -n "${SOPS_AGE_KEY_FILE:-}" ]] && AGE_KEY="$SOPS_AGE_KEY_FILE"
[[ -z "$AGE_KEY" && -f "$HOME/.config/sops/age/keys.txt" ]] && AGE_KEY="$HOME/.config/sops/age/keys.txt"
[[ -z "$AGE_KEY" && -f "$REPO_ROOT/secrets/keys/age/key.txt" ]] && AGE_KEY="$REPO_ROOT/secrets/keys/age/key.txt"

[[ -n "$AGE_KEY" && -f "$AGE_KEY" ]] \
  || die "aucune clé age privée trouvée (essayé: --age-key, \$SOPS_AGE_KEY_FILE, ~/.config/sops/age/keys.txt, secrets/keys/age/key.txt)"
[[ -f "$KEYS_NIX" ]] || die "modules/users/authorized-keys.nix introuvable"
[[ -f "$SOPS_YAML" ]] || die ".sops.yaml introuvable"

PUB_FROM_KEY="$(grep -oE 'age1[0-9a-z]{58}' "$AGE_KEY" | head -1 || true)"
MFO_RECIPIENT="$(grep -oE 'age1[0-9a-z]{58}' "$SOPS_YAML" | head -1 || true)"
[[ -n "$PUB_FROM_KEY" ]] || die "aucune clé publique age trouvée dans $AGE_KEY"
[[ -n "$MFO_RECIPIENT" ]] || die "recipient mfo introuvable dans .sops.yaml"
[[ "$PUB_FROM_KEY" == "$MFO_RECIPIENT" ]] \
  || die "la clé Age fournie correspond à $PUB_FROM_KEY, mais le projet attend $MFO_RECIPIENT"
ok "Clé publique mfo confirmée : $PUB_FROM_KEY"

SSH_KEY="$(grep -oE 'ssh-ed25519 [A-Za-z0-9+/=]+ [^"]+' "$KEYS_NIX" | head -1 || true)"
[[ -n "$SSH_KEY" ]] || die "aucune clé ssh-ed25519 trouvée dans $KEYS_NIX"

step "Cible SSH : $SSH_TARGET"
ssh -o BatchMode=yes -o ConnectTimeout=5 "$SSH_TARGET" true \
  || die "connexion SSH impossible vers $SSH_TARGET"
ok "SSH ok"

step "Dépôt de la clé Age dans /var/lib/sops-nix/key.txt"
ssh "$SSH_TARGET" "sudo install -d -m 0700 -o root -g root /var/lib/sops-nix"
ssh "$SSH_TARGET" "sudo tee /var/lib/sops-nix/key.txt >/dev/null && sudo chmod 0600 /var/lib/sops-nix/key.txt && sudo chown root:root /var/lib/sops-nix/key.txt" \
  < "$AGE_KEY"
ok "Clé Age déposée"

step "Génération des clés d'hôte SSH manquantes"
ssh "$SSH_TARGET" "sudo ssh-keygen -A"
ok "Clés d'hôte SSH prêtes"

step "Ajout de la clé mfo aux authorized_keys courants"
ssh "$SSH_TARGET" "
  set -e
  mkdir -p \$HOME/.ssh
  chmod 700 \$HOME/.ssh
  touch \$HOME/.ssh/authorized_keys
  chmod 600 \$HOME/.ssh/authorized_keys
  grep -qF '$SSH_KEY' \$HOME/.ssh/authorized_keys || echo '$SSH_KEY' >> \$HOME/.ssh/authorized_keys
"
ok "Clé mfo présente côté utilisateur"

step "Installation du bridge OrbStack (rebuild on boot)"
BRIDGE_LOCAL="$REPO_ROOT/targets/hosts/$HOST/orbstack-extras/orbstack-bridge.nix"
if [[ -f "$BRIDGE_LOCAL" ]]; then
  ssh "$SSH_TARGET" "sudo install -m 0644 -o root -g root /dev/stdin /etc/nixos/orbstack-bridge.nix" < "$BRIDGE_LOCAL"
  ssh "$SSH_TARGET" '
    set -e
    if ! sudo grep -qF "./orbstack-bridge.nix" /etc/nixos/configuration.nix; then
      sudo sed -i "s|./orbstack.nix|./orbstack.nix\n      ./orbstack-bridge.nix|" /etc/nixos/configuration.nix
    fi
  '
  ok "Bridge OrbStack installé (rebuild homelab à chaque boot)"
else
  warn "$BRIDGE_LOCAL absent — pas de bridge installé (le host ne survivra pas à un orb stop/start)"
fi

step "Terminé"
log ""
log "Promotion en host '$HOST' (depuis la VM, repo cloné en /etc/infra) :"
log "  ssh $SSH_TARGET 'cd /etc/infra && sudo nix --extra-experimental-features \"nix-command flakes\" run /etc/infra#install-manual -- $HOST'"
log ""
log "Au prochain orb stop/start, le bridge réappliquera automatiquement le flake."

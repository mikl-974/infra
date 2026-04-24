# NixOS configuration for the `homelab` VM.
#
# Composition:
# - `modules/profiles/server.nix` provides the hardened baseline
#   (sudo, SSH key-only, firewall + tailscale0, Tailscale, admin user).
# - `modules/users/root.nix` — enable once secrets/hosts/homelab.yaml
#   contains the `root.passwordHash` key (see module for instructions).
# - `disko.nix` — GPT/EFI/ext4 layout for the virtio block device.
#
# Service stacks are assigned via deployments/inventory.nix.
#
# OrbStack bootstrap requirement
# ------------------------------
# When promoting an existing OrbStack VM into this `homelab` host, the first
# `nixos-rebuild switch` will fail unless:
#   1. `/var/lib/sops-nix/key.txt` exists and is the mfo Age private key — the
#      `admin` and `root` accounts use SOPS-managed password hashes
#      (`neededForUsers = true`), so activation cannot create the users without
#      the key.
#   2. SSH host keys are generated (`ssh-keygen -A`).
#   3. A compatibility user matching the current SSH login on the OrbStack VM
#      stays declared during the switch (NixOS removes undeclared accounts and
#      would kill the live SSH session mid-switch). The `mickael` user below
#      is kept for that reason; it ships mfo's pubkey so the operator can SSH
#      back in even if `admin` is not ready yet.
#
# Run `nix run .#bootstrap-host-on-orbstack` from the Mac host to satisfy
# (1) and (2) before the first promotion switch.
{ config, hostVars, lib, pkgs, ... }:
let
  authorizedKeys = import ../../../modules/users/authorized-keys.nix;
  onOrbstack = builtins.pathExists "/opt/orbstack-guest";
in
{
  imports = [
    ../../../modules/profiles/server.nix
    ../../../modules/users/root.nix
  ];

  networking.hostName = hostVars.hostname;
  time.timeZone       = lib.mkDefault hostVars.timezone;
  i18n.defaultLocale  = lib.mkDefault hostVars.locale;
  system.stateVersion = "24.11";

  # On OrbStack, the VM kernel is provided by the hypervisor and there is no
  # mounted ESP — disable bootloader management to keep the switch persistent.
  # On real bare-metal homelab hardware, /opt/orbstack-guest is absent so
  # systemd-boot is enabled normally. Requires `--impure` so that pathExists
  # can read outside the Nix store; reconfigure.sh passes it.
  boot.loader.systemd-boot.enable      = lib.mkDefault (! onOrbstack);
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault (! onOrbstack);
  boot.loader.grub.enable              = lib.mkDefault (! onOrbstack);

  # OrbStack's vinit (`/opt/orb/vinit`) repoints
  # `/nix/var/nix/profiles/system` back to the auto-generated `nixos-lxc`
  # profile on every boot. To make `homelab` actually persist, re-apply the
  # flake at boot. The repo is expected at `/etc/infra` (cloned at first
  # bootstrap); the unit no-ops if it's missing.
  systemd.services.infra-rebuild-on-boot = lib.mkIf onOrbstack {
    description = "Re-apply NixOS flake config on boot (OrbStack reset workaround)";
    wantedBy = [ "multi-user.target" ];
    after    = [ "network-online.target" "sops-install-secrets.service" ];
    wants    = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = with pkgs; [ nixVersions.stable git ];
    script = ''
      set -eu
      REPO=/etc/infra
      if [ ! -d "$REPO/.git" ]; then
        echo "infra repo absent dans $REPO, rien à faire"
        exit 0
      fi
      CURRENT=$(readlink /run/current-system || true)
      case "$CURRENT" in
        *nixos-system-homelab-2[6-9]*|*nixos-system-homelab-[3-9]*)
          echo "homelab déjà actif: $CURRENT"
          exit 0
          ;;
      esac
      echo "Réapplication de homelab depuis $REPO"
      cd "$REPO"
      git config --global --add safe.directory "$REPO" || true
      exec nixos-rebuild switch --impure --flake "$REPO#homelab" \
        --extra-experimental-features "nix-command flakes"
    '';
  };

  infra.security.sops = {
    enable = true;
    defaultSopsFile = ../../../secrets/hosts/homelab.yaml;
  };

  infra.users.admin.hashedPasswordFile =
    config.sops.secrets."homelab/users/admin-password-hash".path;
  infra.users.admin.sshAuthorizedKeys = authorizedKeys.mfo;

  infra.users.root = {
    enable = true;
    sopsFile = ../../../secrets/common.yaml;
  };

  # OrbStack bootstrap compatibility user. Kept declared so an in-place
  # `nixos-rebuild switch` from the OrbStack default image does not remove
  # the live SSH login. Safe to keep once `admin` is verified.
  users.users.mickael = {
    isNormalUser = true;
    description = "OrbStack migration compatibility user";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = authorizedKeys.mfo;
  };

  services.cockpit = {
    enable = true;
    openFirewall = true;
  };

  sops.secrets."homelab/users/admin-password-hash" = {
    key = "hosts/homelab/users/admin/passwordHash";
    neededForUsers = true;
  };
}

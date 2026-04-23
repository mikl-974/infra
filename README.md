# infra (repo Git: `workstation`)

Ce repo est désormais traité comme un monorepo `infra` :
une seule base pour les briques Nix réutilisables, les machines concrètes,
la composition utilisateur, les dotfiles, les services et les secrets.

## Structure retenue

- `modules/` : briques composables réutilisables
- `targets/` : cibles concrètes
  - `targets/hosts/` : machines réelles
- `home/` : composition Home Manager (`users/`, `roles/`, `targets/`)
- `dotfiles/` : bibliothèque de configs applicatives réutilisables
- `stacks/` : services/applications portés par ce repo
- `secrets/` : secrets chiffrés avec `sops-nix`
- `docs/` : documentation
- `scripts/` : orchestration légère / validation

Voir `docs/repo-structure.md` et `docs/architecture.md`.

## Frontières d’architecture

- `modules/` = logique réutilisable
- `targets/hosts/<name>/` = réalité d’une machine
- `home/` = qui utilise quoi, sur quelle machine
- `dotfiles/` = contenu brut applicatif, jamais le binding
- `stacks/` = services/applicatifs, pas composition machine
- `secrets/` = fondation chiffrée, pas de secrets en clair

## Users réels

Les premiers users posés explicitement sont :
- `mfo` = Mickaël Folio
- `dfo` = Delphine Folio

Leurs identités Home Manager sont dans `home/users/`.
Leur composition finale par machine est dans `home/targets/`.

## Cas concret : `ms-s1-max`

Le target `ms-s1-max` valide le modèle complet.

### Système machine
`targets/hosts/ms-s1-max/` déclare :
- Hyprland + GNOME
- gaming (Steam/Lutris côté système)
- Tailscale
- Cloudflare WARP
- stack `ai-server`
- base `sops-nix`

### Composition utilisateur
`home/targets/ms-s1-max.nix` compose :
- `mfo` → Hyprland, Steam, Chromium
- `dfo` → GNOME, Lutris, Steam, Firefox, Kitty

### Limite explicite
NordVPN est bien une capacité visée pour `ms-s1-max`, mais reste **documentée seulement** tant que `nixpkgs` ne fournit pas de package/module officiel exploitable sur la base retenue.

## `stacks/` est conservé

`stacks/` fait pleinement partie du repo `infra`.
Il décrit les services/applications portés par ce repo.

Exemple actuel :
- `stacks/ai-server/` = service `ollama` côté infra

La machine qui le porte est choisie dans `targets/hosts/<name>/default.nix` via un profil système (`modules/profiles/ai-server.nix`).

## `sops-nix`

La base secrets retenue est `sops-nix`.

Intégration posée :
- input flake `sops-nix`
- module réutilisable `modules/security/sops.nix`
- activation cible par `infra.security.sops.enable = true;`
- documentation dans `secrets/README.md`

## Nix unstable

Les packages suivent `nixos-unstable` via l’input `nixpkgs` du `flake.nix`.

## Commandes utiles

```bash
# init vars d'une machine
nix run .#init-host -- ms-s1-max

# audit local
nix run .#doctor -- --host ms-s1-max
nix run .#validate-install -- ms-s1-max

# afficher la config machine
nix run .#show-config -- ms-s1-max
```

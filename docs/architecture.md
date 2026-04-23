# Architecture du repo `infra`

## Principe

Le repo Git s'appelle encore `workstation`, mais son rôle cible est désormais `infra`.
Il ne sépare plus artificiellement `homelab` et `workstation` :
la structure interne porte désormais ensemble les machines, les users, les dotfiles,
les services et les secrets.

## Couches retenues

| Couche | Rôle | Exemple |
|---|---|---|
| `modules/` | briques réutilisables | desktop, shell, theming, profiles, security, devshells |
| `targets/hosts/` | machines réelles | `main`, `laptop`, `gaming`, `ms-s1-max` |
| `home/users/` | identité HM d’un user | `mfo.nix`, `dfo.nix` |
| `home/roles/` | rôles HM composables | `desktop-hyprland.nix`, `browser-firefox.nix` |
| `home/targets/` | binding final par machine | `ms-s1-max.nix` |
| `dotfiles/` | contenu brut applicatif | Hyprland, Kitty, Wofi, Mako |
| `stacks/` | services/applicatifs | `ai-server/` |
| `secrets/` | secrets chiffrés | base `sops-nix` |

## Règles de composition

### 1. `modules/`
Contient uniquement des briques réutilisables.
Il ne contient jamais une machine concrète.

### 2. `targets/hosts/`
Contient la vérité machine :
- `vars.nix`
- `default.nix`
- `disko.nix` si nécessaire

### 3. `home/`
Contient la logique utilisateur :
- `home/users/` = identité
- `home/roles/` = rôles composables
- `home/targets/` = composition finale par machine

### 4. `dotfiles/`
Contient uniquement du contenu brut.
Le choix de quel user consomme quel dotfile se fait dans `home/`.

### 5. `stacks/`
Contient des services/applications.
Une stack peut fournir un module de service, mais ne choisit jamais elle-même la machine cible.

## Flux de composition

1. `targets/hosts/<name>/default.nix` compose des profils système depuis `modules/profiles/`
2. un profil système peut importer une stack (`modules/profiles/ai-server.nix` → `stacks/ai-server/`)
3. `flake.nix` choisit la composition Home Manager :
   - si `home/targets/<hostname>.nix` existe, elle est utilisée
   - sinon fallback sur `home/users/default.nix`
4. `home/targets/<hostname>.nix` assigne des users + rôles
5. les rôles Home Manager lient les dotfiles et ajoutent les apps utilisateur

## Cas de référence : `ms-s1-max`

### Côté système
`targets/hosts/ms-s1-max/default.nix` active :
- `desktop-hyprland`
- `desktop-gnome`
- `gaming`
- `networking`
- `ai-server`
- `sops-nix`

### Côté users
`home/targets/ms-s1-max.nix` compose :
- `mfo` = `desktop-hyprland` + `gaming-steam` + `browser-chromium`
- `dfo` = `desktop-gnome` + `gaming-lutris` + `gaming-steam` + `browser-firefox` + `terminal-kitty`

## `stacks/` reste dans le repo

`stacks/` fait partie du repo `infra`.
La frontière est :
- `modules/` = logique système réutilisable
- `targets/hosts/` = machines concrètes
- `stacks/` = services/applicatifs
- `home/` = composition utilisateur

## Secrets

Le repo retient `sops-nix` comme stratégie secrets.
La fondation est :
- input flake `sops-nix`
- module `modules/security/sops.nix`
- activation par host via `infra.security.sops.enable`

## Nix packages

Les packages suivent `nixos-unstable` via `nixpkgs`.

# workstation

Repository dédié aux machines utilisateur personnelles (NixOS desktop, Hyprland, dotfiles, devShells), séparé du scope `homelab`.

## Dépendance partagée : `foundation`

Ce repo consomme [`mikl-974/foundation`](https://github.com/mikl-974/foundation) comme socle partagé.

Briques consommées depuis `foundation` :

| Brique | Source | Raison |
|---|---|---|
| Tailscale | `foundation.nixosModules.networkingTailscale` | réseau générique, partagé entre machines |
| devShell `.NET` | `foundation.devShells.<system>.dotnet` | outillage générique, sans spécificité desktop |

Briques conservées dans `workstation` :

| Brique | Raison |
|---|---|
| Hyprland + base desktop | spécifique machines utilisateur |
| Cloudflare WARP | client VPN desktop, pas une primitive infra générique |
| theming / dotfiles | strictement desktop / utilisateur |

## Structure

- `hosts/` : définition des machines concrètes (`main`, `laptop`, `gaming`)
- `profiles/` : assemblages réutilisables (`desktop-hyprland`, `dev`, `gaming`, `networking`)
- `modules/` : modules Nix ciblés par domaine (`desktop/`, `apps/`, `shell/`, `theming/`)
- `home/` : base Home Manager
- `dotfiles/` : configurations applicatives versionnées
- `docs/` : documentation d'architecture et d'usage
- `flake.nix` : point d'entrée unique

## Séparation des responsabilités

- **host** : identité machine + combinaison de profils
- **profile** : composition de briques fonctionnelles
- **module** : logique Nix isolée et réutilisable
- **dotfiles** : configuration applicative versionnée
- **devShell** : outillage dev reproductible

## Base Hyprland minimale

La base desktop est portée par `profiles/desktop-hyprland.nix` via `modules/desktop/` et inclut :

- Hyprland + XWayland
- session de login via `greetd` + `tuigreet`
- xdg-desktop-portal (Hyprland)
- PipeWire + RTKit
- polkit
- NetworkManager
- Cloudflare WARP (`modules/desktop/warp.nix`)
- terminal (`foot`)
- launcher (`wofi`)
- outils Wayland de base (`waybar`, `wl-clipboard`, `grim`, `slurp`)

## Réseau : Tailscale via `foundation`

Tailscale est activé via `profiles/networking.nix` en consommant le module `foundation.nixosModules.networkingTailscale`.

Ce profil est importé par tous les hosts (`main`, `laptop`, `gaming`).

## DevShell .NET

Entrer dans le shell :

```bash
nix develop .#dotnet
```

Le shell `.NET` est fourni par `foundation` — pas de duplication locale.
Si un besoin spécifique workstation apparaît plus tard, il s'étend localement dans `flake.nix` sans toucher `foundation`.

Le shell inclut (via `foundation`) : `dotnet-sdk`, `git`, `curl`, `jq`, `openssl`, `pkg-config`.

## Hosts

- `main` : base desktop + profil dev + réseau (Tailscale + WARP)
- `laptop` : base desktop + profil dev + réseau
- `gaming` : base desktop + profil gaming + réseau

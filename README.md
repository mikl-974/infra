# workstation

Repository dédié aux machines utilisateur personnelles (NixOS desktop, Hyprland, dotfiles, devShells), séparé du scope `homelab`.

## Dépendance partagée : `foundation`

Ce repo consomme [`mikl-974/foundation`](https://github.com/mikl-974/foundation) comme socle partagé.

Briques consommées depuis `foundation` :

| Brique | Source | Raison |
|---|---|---|
| Tailscale | `foundation.nixosModules.networkingTailscale` | réseau générique, partagé entre machines |

Briques conservées dans `workstation` :

| Brique | Raison |
|---|---|
| devShell `.NET` | environnement de dev personnel (Docker, IDE) — pas une brique générique |
| Hyprland + base desktop | spécifique machines utilisateur |
| Cloudflare WARP | client VPN desktop, pas une primitive infra générique |
| theming / dotfiles | strictement desktop / utilisateur |

## Structure

- `hosts/` : définition des machines concrètes (`main`, `laptop`, `gaming`)
- `profiles/` : assemblages réutilisables (`desktop-hyprland`, `dev`, `gaming`, `networking`)
- `modules/` : modules Nix ciblés par domaine (`desktop/`, `apps/`, `shell/`, `theming/`)
- `devshells/` : environnements de développement locaux (spécifiques au poste)
- `home/` : base Home Manager
- `dotfiles/` : configurations applicatives versionnées
- `docs/` : documentation d'architecture et d'usage
- `flake.nix` : point d'entrée unique

## Séparation des responsabilités

- **host** : identité machine + combinaison de profils
- **profile** : composition de briques fonctionnelles
- **module** : logique Nix isolée et réutilisable
- **dotfiles** : configuration applicative versionnée
- **devShell** : outillage dev local, spécifique au poste de travail

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

## DevShell .NET (local)

Entrer dans le shell :

```bash
nix develop .#dotnet
```

Le shell `.NET` est défini localement dans `devshells/dotnet.nix`.
Il représente l'environnement de développement personnel du poste.
Il n'est pas consommé depuis `foundation` — ce n'est pas une brique générique.

Contenu : `dotnet-sdk`, `git`, `curl`, `jq`, `openssl`, `pkg-config`, `docker-client`.

## Hosts

- `main` : base desktop + profil dev + réseau (Tailscale + WARP)
- `laptop` : base desktop + profil dev + réseau
- `gaming` : base desktop + profil gaming + réseau

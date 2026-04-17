# workstation

Repository dédié aux machines utilisateur personnelles (NixOS desktop, Hyprland, dotfiles, devShells), séparé du scope `homelab`.

## Structure

- `hosts/` : définition des machines concrètes (`main`, `laptop`, `gaming`)
- `profiles/` : assemblages réutilisables (desktop, dev, gaming)
- `modules/` : modules Nix ciblés par domaine (desktop, apps, shell, theming)
- `home/` : base Home Manager
- `devshells/` : environnements de développement Nix
- `dotfiles/` : futur stockage des configurations applicatives
- `docs/` : documentation d’architecture et d’usage
- `flake.nix` : point d’entrée unique

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
- terminal (`foot`)
- launcher (`wofi`)
- outils Wayland de base (`waybar`, `wl-clipboard`, `grim`, `slurp`)

## DevShell .NET

Entrer dans le shell :

```bash
nix develop .#dotnet
```

Le shell inclut : `dotnet-sdk`, `git`, `curl`, `jq`, `openssl`, `pkg-config`.

## Hosts

- `main` : base desktop + profil dev
- `laptop` : base desktop + profil dev (base prête à spécialiser)
- `gaming` : base desktop + profil gaming

# Base Hyprland

## Localisation

La base desktop Hyprland est organisée ainsi :

- profil : `profiles/desktop-hyprland.nix`
- modules :
  - `modules/desktop/default.nix`
  - `modules/desktop/hyprland.nix`
  - `modules/desktop/audio.nix`
  - `modules/desktop/portals.nix`
  - `modules/desktop/fonts.nix`

## Composition actuelle

La base inclut :

- Hyprland + XWayland
- login manager simple (`greetd` + `tuigreet`)
- PipeWire
- xdg portal Hyprland
- polkit
- NetworkManager
- terminal (`foot`)
- launcher (`wofi`)
- outils Wayland minimaux (`waybar`, `wl-clipboard`, `grim`, `slurp`)

## Ce qui n’est volontairement pas inclus

- aucun rice/thème lourd
- aucune surcharge visuelle
- aucune logique utilisateur cachée

## Étendre proprement

- ajouter la logique desktop commune dans `modules/desktop/`
- garder les choix machine-spécifiques dans `hosts/`
- déplacer la personnalisation utilisateur dans `dotfiles/` + `home/`

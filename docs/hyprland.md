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
  - `modules/desktop/warp.nix`

## Composition actuelle

La base inclut :

- Hyprland + XWayland
- login manager simple (`greetd` + `tuigreet`)
- PipeWire
- xdg portal Hyprland
- polkit
- NetworkManager
- Cloudflare WARP
- terminal (`foot`)
- launcher (`wofi`)
- outils Wayland minimaux (`waybar`, `wl-clipboard`, `grim`, `slurp`)

Tailscale est activé via `profiles/networking.nix` (module `foundation`), pas depuis le profil desktop.

## Ce qui n'est volontairement pas inclus

- aucun rice/thème lourd
- aucune surcharge visuelle
- aucune logique utilisateur cachée
- Tailscale n'est pas dans ce profil (il vient de `foundation` via `profiles/networking.nix`)

## Cloudflare WARP

WARP est géré dans `modules/desktop/warp.nix` et activé via `profiles/desktop-hyprland.nix`.

Il reste dans `workstation` parce que c'est un client VPN desktop (interface utilisateur), pas une primitive réseau serveur. Le module `foundation.networking.cloudflared` (tunnel daemon) est une brique différente et distincte.

## Étendre proprement

- ajouter la logique desktop commune dans `modules/desktop/`
- garder les choix machine-spécifiques dans `hosts/`
- déplacer la personnalisation utilisateur dans `dotfiles/` + `home/`
- ne pas ajouter de logique réseau ici — utiliser `profiles/networking.nix`

# Composition utilisateur

## Règle

- `home/users/` = identité + overrides user utiles
- `home/roles/` = binding réutilisable commun
- `home/targets/` = assemblage final par machine
- `dotfiles/` = contenu brut, jamais la décision finale

## Cas `ms-s1-max`

### `mfo`
- rôles : Hyprland, Steam, Chromium
- dotfiles réellement actifs :
  - `dotfiles/hyprland/hyprland.conf`
  - `dotfiles/hyprland/profiles/mfo.conf`
  - `dotfiles/terminal/foot.ini`
  - `dotfiles/launchers/config`
  - `dotfiles/launchers/style.css`
  - `dotfiles/notifications/config`

### `dfo`
- rôles : GNOME, Lutris, Steam, Firefox, Kitty
- dotfiles réellement actifs :
  - `dotfiles/terminal/kitty.conf`
  - `dotfiles/terminal/profiles/dfo-kitty.conf`
  - `dotfiles/themes/noctalia/gtk/settings.ini`

## Cas `main`

### `mikl`
- rôles : Hyprland
- dotfiles réellement actifs :
  - `dotfiles/hyprland/hyprland.conf`
  - `dotfiles/hyprland/profiles/default.conf`
  - `dotfiles/terminal/foot.ini`
  - `dotfiles/launchers/config`
  - `dotfiles/launchers/style.css`
  - `dotfiles/notifications/config`

## Legacy

`home/users/default.nix` reste seulement pour les hosts non migrés.
`main` et `ms-s1-max` n'en dépendent plus ; il ne couvre plus que `laptop` et `gaming`.
Les nouveaux bindings doivent partir de `home/targets/`.

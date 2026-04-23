# home/

Composition Home Manager des users, rôles et targets.

## Rôle

`home/` est l’endroit où l’on décide :
- quels users existent côté Home Manager
- quels rôles leur sont appliqués
- comment cela varie selon la machine
- quels dotfiles sont liés

## Structure

| Dossier | Rôle |
|---|---|
| `home/users/` | identité d’un user (`base.nix`, `mfo.nix`, `dfo.nix`) |
| `home/roles/` | rôles composables (`desktop-hyprland`, `desktop-gnome`, `browser-*`, `gaming-*`, `terminal-kitty`) |
| `home/targets/` | composition finale par target (`ms-s1-max.nix`) |

## Règle

- `home/users/` ne décide pas seul de la machine
- `home/roles/` ne contient pas de dotfiles machine-spécifiques cachés
- `home/targets/` est le binding explicite user/role/target

## Exemple

`home/targets/ms-s1-max.nix` compose :
- `mfo` avec Hyprland + Steam + Chromium
- `dfo` avec GNOME + Lutris + Steam + Firefox + Kitty

# Theming — Noctalia

## Architecture

Le theming repose sur **Noctalia Shell**, un shell desktop complet (barre, launcher, control center) basé sur Quickshell.

| Couche | Localisation | Rôle |
|---|---|---|
| Module système | `modules/theming/noctalia.nix` | Packages GTK/curseur, env vars, activation |
| Module Home Manager | `home/noctalia.nix` | Configuration Noctalia (barre, couleurs, widgets) via le module HM officiel |

## Activation

Noctalia est activé dans `profiles/desktop-hyprland.nix` :

```nix
workstation.theming.noctalia.enable = true;
```

Tous les hosts qui importent `desktop-hyprland.nix` héritent de Noctalia.

## Module système (`modules/theming/noctalia.nix`)

Installe le package `noctalia-shell` depuis le flake input, plus les packages GTK/curseur.
Configure `GTK_THEME=Adwaita:dark`.

## Module Home Manager (`home/noctalia.nix`)

Importe `inputs.noctalia.homeModules.default` et configure :
- Position de la barre, type, widgets
- Schéma de couleurs (prédéfini Rose Pine)
- Paramètres de localisation

La configuration est entièrement déclarative — pas de fichiers dotfiles manuels.

## Flake input

```nix
noctalia = {
  url = "github:noctalia-dev/noctalia-shell";
  inputs.nixpkgs.follows = "nixpkgs-unstable";
};
```

Cache binaire configuré dans `nixConfig` du flake.

## Intégration Hyprland

- `exec-once = noctalia-shell` dans `dotfiles/hypr/hyprland.conf`
- `bind = $mod, Space, exec, noctalia-shell ipc call launcher toggle`

## Qt software rendering

Sur les machines sans accélération GPU :

```nix
QT_QUICK_BACKEND = "software";  # dans modules/desktop/hyprland.nix
```

## Modifier la configuration

Éditer `home/noctalia.nix` — section `programs.noctalia-shell.settings`.

Documentation officielle : https://docs.noctalia.dev/

| Couche | Localisation | Role |
|---|---|---|
| Module systeme | `modules/theming/noctalia.nix` | packages GTK, env vars, activation |
| Assets visuels | `dotfiles/noctalia/` | couleurs, wallpapers, CSS applicatifs |

Ces deux couches sont intentionnellement separees : le module Nix gere ce qui releve du systeme, les dotfiles gerent ce qui releve de la personnalisation visuelle brute.

## Activation

Noctalia est active dans `profiles/desktop-hyprland.nix` :

```nix
workstation.theming.noctalia.enable = true;
```

Tous les hosts qui importent `desktop-hyprland.nix` heritent de Noctalia.
Si un host ne doit pas avoir le theme, il ne doit pas importer ce profil.

## Module systeme (`modules/theming/noctalia.nix`)

Ce module installe :
- `adwaita-icon-theme`
- `gnome-themes-extra`
- `bibata-cursors`

Et configure :
- `GTK_THEME=Adwaita:dark` (variable de session — peut etre surchargee par home-manager)

## Dotfiles visuels (`dotfiles/noctalia/`)

La palette de couleurs et les assets visuels vivent dans `dotfiles/noctalia/`.

Structure prevue :

```
dotfiles/noctalia/
  colors.conf          palette de base (variables nommees)
  wallpaper/           fonds d'ecran
  gtk/                 surcharges CSS GTK
  waybar/              style.css waybar
  foot/                snippet couleurs foot (inclus dans foot.ini)
```

Les fichiers de ce dossier sont lies par Home Manager (`home/default.nix`).

## Etendre Noctalia

### Ajouter un package systeme

Dans `modules/theming/noctalia.nix`, section `environment.systemPackages`.

### Ajouter un fichier de theme applicatif

1. Placer le fichier dans `dotfiles/noctalia/`
2. L'enregistrer dans `home/default.nix` via `home.file`

### Changer le theme GTK

Modifier `environment.sessionVariables.GTK_THEME` dans `noctalia.nix`,
ou surcharger via `home-manager.users.<user>.gtk.theme`.

## Ajouter un second theme

Creer `modules/theming/<nom>.nix` en suivant le meme pattern que `noctalia.nix`.
Exposer une option `workstation.theming.<nom>.enable`.
Ne pas activer deux themes en meme temps sans gerer les conflits de variables.

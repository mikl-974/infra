# dotfiles/

Bibliothèque de configurations applicatives réutilisables.

## Règle

Ce dossier est organisé par application ou domaine, pas par machine ou utilisateur.

Les dotfiles ici peuvent être utilisés par :
- plusieurs utilisateurs
- plusieurs targets
- plusieurs rôles

Le binding concret (quel utilisateur utilise quel dotfile) est dans `home/users/`.

## Structure

| Dossier | Application |
|---|---|
| `dotfiles/hyprland/` | Hyprland (compositeur Wayland) |
| `dotfiles/terminal/` | Foot (terminal) |
| `dotfiles/launchers/` | Wofi (lanceur d'applications) |
| `dotfiles/notifications/` | Mako (daemon de notifications) |
| `dotfiles/themes/noctalia/` | Noctalia (schéma de couleurs et thème) |
| `dotfiles/shell/` | Configuration shell |
| `dotfiles/editors/` | Éditeurs (VS Code, Rider, etc.) |

## Étendre

Pour ajouter un nouveau dotfile :
1. Créer le fichier dans le bon sous-dossier (ex: `dotfiles/launchers/`)
2. Le lier depuis `home/users/default.nix` via `home.file`
3. Documenter ici si nécessaire

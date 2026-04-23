# dotfiles/

Bibliothèque réutilisable de configurations applicatives.

## Règle

Ce dossier contient uniquement du contenu brut applicatif.
Il n’exprime jamais quel user ou quelle machine consomme un fichier.

Le binding se fait dans `home/` :
- `home/roles/` pour les ensembles réutilisables
- `home/targets/` pour la composition finale par machine

## Structure actuelle

| Dossier | Rôle |
|---|---|
| `dotfiles/hyprland/` | config Hyprland |
| `dotfiles/terminal/` | configs terminal (`foot.ini`, `kitty.conf`) |
| `dotfiles/launchers/` | launcher |
| `dotfiles/notifications/` | notifications |
| `dotfiles/themes/noctalia/` | assets de thème |
| `dotfiles/shell/` | shell |
| `dotfiles/editors/` | éditeurs |

## Multi-user / multi-target

La flexibilité vient de la séparation suivante :
- dotfiles = contenu brut
- roles HM = ensembles réutilisables
- targets HM = affectation finale par machine

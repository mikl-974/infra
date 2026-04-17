# dotfiles

`dotfiles/` centralise les configurations applicatives utilisateur (Hyprland, shell, terminal, launcher, theming Noctalia, etc.).

## Règles d’organisation

- Un dossier par application (`hypr/`, `shell/`, `foot/`, `wofi/`, ...)
- Fichiers lisibles, nommés explicitement
- Pas de mélange avec les modules Nix système
- Pas de fichiers temporaires ou générés

## Intégration recommandée

- Conserver les dotfiles bruts ici
- Les lier ensuite depuis Home Manager/Nix selon la machine ou le profil
- Garder la personnalisation séparée de la base système

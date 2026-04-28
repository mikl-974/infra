# MangoWM

MangoWM est un window manager basé sur i3 avec des améliorations, utilisé en alternative à Hyprland dans ce projet.

## Caractéristiques

- **Base i3** : Utilise le même modèle que i3 mais avec des fonctionnalités supplémentaires
- **Wayland** : Support complet de Wayland avec XWayland pour l'application X11
- **UWSM** : Intégration avec User Window Session Manager pour la gestion de session
- **Flake officiel** : Utilise le flake officiel de MangoWM via flakebox

## Installation

Pour utiliser MangoWM au lieu de Hyprland, modifiez votre configuration :

```nix
# Dans votre configuration NixOS
workstation.desktop.windowManager.mangowm.enable = true;
workstation.desktop.windowManager.hyprland.enable = false;
```

## Structure

Le module MangoWM inclut :

- Configuration de base de MangoWM
- Intégration avec UWSM
- Support XWayland
- Variables d'environnement Wayland
- Paquets de base (wl-clipboard, grim, slurp, foot)

## Ce qui n'est pas inclus

- Les applications quotidiennes -> `systems/bundles/daily.nix`
- La connectivité locale (Bluetooth, NetworkManager) -> `systems/desktop/connectivity.nix`
- Le theming -> `systems/profiles/desktop-mangowm.nix`

## Documentation

- [Documentation officielle MangoWM](https://github.com/mangohud-org/mangohud)
- [Flakebox MangoWM](https://flakebox.com/mangowm)

## Migration de Hyprland vers MangoWM

Pour migrer de Hyprland à MangoWM :

1. Désactivez Hyprland dans votre configuration
2. Activez MangoWM
3. Copiez votre configuration i3 dans `dotfiles/hyprland/hyprland.conf` vers `~/.config/mangowm/config`
4. Adaptez les bindings si nécessaire (MangoWM utilise des commandes i3 classiques)

## Notes

- MangoWM est un fork de i3 avec des améliorations pour Wayland
- Il partage beaucoup de similarités avec i3, ce qui facilite la migration
- Les scripts i3 classiques fonctionnent généralement sans modification

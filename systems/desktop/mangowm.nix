{ lib, config, pkgs, ... }:

{
  # MangoWM est un window manager basé sur i3 avec des améliorations.
  # Il utilise le même modèle que i3 mais avec des fonctionnalités supplémentaires.
  #
  # Documentation officielle : https://github.com/mangohud-org/mangohud
  # Flake officiel : https://flakebox.com/mangowm
  #
  # Scope:
  #   - Configuration de base de MangoWM
  #   - Intégration avec UWSM (User Window Session Manager)
  #   - Support XWayland
  #   - Variables d'environnement Wayland
  #
  # Ce qui n'est pas inclus ici:
  #   - Les applications quotidiennes (elles sont dans systems/bundles/daily.nix)
  #   - La connectivité locale (Bluetooth, NetworkManager) -> systems/desktop/connectivity.nix
  #   - Le theming -> systems/profiles/desktop-mangowm.nix

  # Activer MangoWM
  programs.mangowm = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # Variables d'environnement pour MangoWM/Wayland
  environment.sessionVariables = {
    NIXOS_OZONE_WL          = "1";
    XDG_CURRENT_DESKTOP     = "MangoWM";
    XDG_SESSION_TYPE        = "wayland";
    # Fallback pour les VMs et machines sans curseur HW Wayland
    WLR_NO_HARDWARE_CURSORS = "1";
    # Forcer le renderer software si pas de GPU Vulkan/DRM
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
    # Qt/MangoWM — software rendering fallback (EGL surface errors)
    QT_QPA_PLATFORM         = "wayland";
    QT_QUICK_BACKEND        = "software";
  };

  # Paquets de base pour MangoWM
  environment.systemPackages = with pkgs; [
    # Outils Wayland minimaux
    wl-clipboard
    grim
    slurp
    # Terminal
    foot
  ];
}

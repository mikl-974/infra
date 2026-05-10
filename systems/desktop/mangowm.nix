{ pkgs, ... }:

{
  # Mango est un compositeur Wayland expose via son flake officiel.
  #
  # Documentation officielle : https://github.com/mangowm/mango
  #
  # Scope:
  #   - Activation du compositeur Mango via son module officiel
  #   - Outils Wayland communs pour l'utiliser en session desktop
  #
  # Ce qui n'est pas inclus ici:
  #   - Les applications quotidiennes (elles sont dans systems/bundles/daily.nix)
  #   - La connectivité locale (Bluetooth, NetworkManager) -> systems/desktop/connectivity.nix
  #   - La config utilisateur Mango Home Manager

  programs.mango = {
    enable = true;
  };

  # Variables d'environnement Wayland communes. Les variables de session
  # specifiques au compositeur ne doivent pas etre globales si Mango et
  # Hyprland coexistent sur la meme machine.
  environment.sessionVariables = {
    BROWSER = "chromium-browser";
    XDG_CURRENT_DESKTOP = "wlroots";
    GTK_USE_PORTAL = "1";
    
    # Force Wayland pour d'autres Toolkits
    NIXOS_OZONE_WL = "1"; # Force Wayland pour la majorité des apps Electron
    MOZ_ENABLE_WAYLAND = "1"; # pour Firefox
    
    WLR_NO_HARDWARE_CURSORS = "1";
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
    QT_QPA_PLATFORM         = "wayland";
  };

  environment.systemPackages = with pkgs; [
    wl-clipboard
    grim
    slurp
    foot
  ];
}

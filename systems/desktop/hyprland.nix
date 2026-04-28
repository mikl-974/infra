{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL          = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
    QT_QPA_PLATFORM         = "wayland";
    QT_QUICK_BACKEND        = "software";
  };

  environment.systemPackages = with pkgs; [
    wl-clipboard
    grim
    slurp
  ];
  
  # home.packages is managed by Home Manager, not NixOS
  # See: https://wiki.nixos.org/wiki/Configuration_Scope
}

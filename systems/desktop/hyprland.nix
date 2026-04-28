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
  };

  environment.systemPackages = with pkgs; [
    wl-clipboard
    grim
    slurp
  ];
}

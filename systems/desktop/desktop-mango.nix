{ pkgs, ... }:
{
  home.packages = with pkgs; [
    foot
    rofi-wayland
    waybar
    swaybg
    mako
    wl-clipboard
    cliphist
    wlsunset
    grim
    slurp
    swaylock
    swayidle
    polkit_gnome
  ];
}

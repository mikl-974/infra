{ config, pkgs, ... }:
let
  sessionData = config.services.displayManager.sessionData;
in
{
  imports = [
    ./hyprland.nix
    ./mangowm.nix
    ./audio.nix
    ./connectivity.nix
    ./portals.nix
    ./fonts.nix
    ./warp.nix
  ];

  hardware.graphics.enable = true;
  # Load DRM modules at boot (Intel, AMD, virtio-gpu)
  # — silently ignored if the hardware is absent
  boot.initrd.kernelModules = [ "drm" ];
  boot.kernelModules        = [ "i915" "amdgpu" "virtio-gpu" ];
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  security.polkit.enable = true;
  services.dbus.enable = true;
  services.greetd.enable = true;
  services.greetd.settings.default_session = {
    # Expose all installed Wayland sessions so the user can choose Mango or
    # Hyprland from tuigreet. Pass NixOS' generated session directory
    # explicitly: tuigreet's upstream defaults look under /usr/share, which is
    # empty/non-existent on NixOS and can leave greetd restarting without a
    # visible greeter after nixpkgs updates.
    command = ''
      ${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --sessions ${sessionData.desktops}/share/wayland-sessions --xsessions ${sessionData.desktops}/share/xsessions --session-wrapper ${sessionData.wrapper} --cmd "${pkgs.uwsm}/bin/uwsm start -e -D Hyprland hyprland.desktop"
    '';
    user = "greeter";
  };
}

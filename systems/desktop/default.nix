{ pkgs, ... }:
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
    # Hyprland from tuigreet instead of hardcoding a single compositor.
    command = ''
      ${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session
    '';
    user = "greeter";
  };
}

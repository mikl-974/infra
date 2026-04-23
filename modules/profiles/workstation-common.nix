# Common NixOS workstation baseline shared by main, laptop, and gaming.
# Import this profile first, then layer host-specific profiles (dev, gaming…)
# and the host-local user.nix on top.
{ hostVars, ... }:
{
  imports = [
    ./desktop-hyprland.nix
    ./networking.nix
  ];

  networking.hostName = hostVars.hostname;
  time.timeZone      = hostVars.timezone;
  i18n.defaultLocale = hostVars.locale;
  system.stateVersion = "24.11";

  # EFI systemd-boot — matches the disko ESP layout at /boot.
  boot.loader.systemd-boot.enable      = true;
  boot.loader.efi.canTouchEfiVariables = true;
}

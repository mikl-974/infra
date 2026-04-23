{ hostVars, ... }:
{
  imports = [
    ../../modules/profiles/desktop-hyprland.nix
    ../../modules/profiles/dev.nix
    ../../modules/profiles/networking.nix
  ];

  networking.hostName = hostVars.hostname;
  time.timeZone = hostVars.timezone;
  i18n.defaultLocale = hostVars.locale;
  system.stateVersion = "24.11";

  # Boot: EFI systemd-boot — explicit for install/reinstall reliability.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  users.users.${hostVars.username} = {
    isNormalUser = true;
    extraGroups  = [ "wheel" "docker" "networkmanager" "video" "audio" ];
  };
}

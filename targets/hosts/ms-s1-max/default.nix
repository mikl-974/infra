{ lib, hostVars, ... }:
{
  imports = [
    ../../modules/profiles/desktop-hyprland.nix
    ../../modules/profiles/desktop-gnome.nix
    ../../modules/profiles/gaming.nix
    ../../modules/profiles/networking.nix
    ../../modules/profiles/ai-server.nix
  ];

  networking.hostName = hostVars.hostname;
  time.timeZone = hostVars.timezone;
  i18n.defaultLocale = hostVars.locale;
  system.stateVersion = "24.11";

  services.greetd.enable = lib.mkForce false;

  users.users.mfo = {
    isNormalUser = true;
    description = "Mickaël Folio";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
  };

  users.users.dfo = {
    isNormalUser = true;
    description = "Delphine Folio";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
  };

  infra.security.sops.enable = true;

  warnings = [
    "NordVPN is part of the conceptual target capability for ms-s1-max, but nixpkgs 24.11 does not provide an official supported NordVPN package/module. Keep this capability documented until upstream support exists."
  ];
}

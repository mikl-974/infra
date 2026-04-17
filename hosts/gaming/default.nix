{ ... }:
{
  imports = [
    ../../profiles/desktop-hyprland.nix
    ../../profiles/gaming.nix
  ];

  networking.hostName = "gaming";
  system.stateVersion = "24.11";
}

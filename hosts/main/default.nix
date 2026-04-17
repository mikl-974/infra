{ ... }:
{
  imports = [
    ../../profiles/desktop-hyprland.nix
    ../../profiles/dev.nix
    ../../profiles/networking.nix
  ];

  networking.hostName = "main";
  system.stateVersion = "24.11";
}

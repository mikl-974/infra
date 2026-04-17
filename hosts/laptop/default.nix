{ ... }:
{
  imports = [
    ../../profiles/desktop-hyprland.nix
    ../../profiles/dev.nix
  ];

  networking.hostName = "laptop";
  system.stateVersion = "24.11";
}

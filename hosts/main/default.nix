{ ... }:
{
  imports = [
    ../../profiles/desktop-hyprland.nix
    ../../profiles/dev.nix
  ];

  networking.hostName = "main";
  system.stateVersion = "24.11";
}

{ pkgs, ... }:
{
  imports = [
    ../apps/steam.nix
    ../apps/gaming-mode.nix
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  
  programs.gamemode.enable = true;

  environment.systemPackages = import ../../catalog/bundles/gaming.nix { inherit pkgs; };
}

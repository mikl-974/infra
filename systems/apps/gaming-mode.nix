{ pkgs, ... }:
{
  programs.gamemode.enable = true;

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  environment.systemPackages = import ../../catalog/apps/gaming-mode.nix { inherit pkgs; };
}

{ pkgs, ... }:
{
  imports = [
    ./utilities.nix
  ];

  environment.systemPackages = with pkgs; [
    xdg-utils
    file
    ripgrep
  ];
}

{ pkgs, ... }:
{
  environment.systemPackages = import ../../catalog/apps/wine.nix { inherit pkgs; };
}

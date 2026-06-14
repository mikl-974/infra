{ pkgs, ... }:
{
  environment.systemPackages = import ../../catalog/apps/element-desktop.nix { inherit pkgs; };
}

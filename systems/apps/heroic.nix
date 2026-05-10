{ pkgs, ... }:
{
  environment.systemPackages = import ../../catalog/apps/heroic.nix { inherit pkgs; };
}

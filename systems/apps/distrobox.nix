{ pkgs, ... }:
{
  environment.systemPackages = import ../../catalog/apps/distrobox.nix { inherit pkgs; };
}

{ pkgs, ... }:
{
  environment.systemPackages = import ../../catalog/apps/proton.nix { inherit pkgs; };
}

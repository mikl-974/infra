{ pkgs, ... }:
{

  environment.systemPackages = import ../../catalog/bundles/rider-workstation.nix { inherit pkgs; };
}

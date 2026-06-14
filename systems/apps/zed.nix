{ pkgs, ... }:
{
  environment.systemPackages = import ../../catalog/apps/zed.nix { inherit pkgs; };
}

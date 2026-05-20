{ pkgs, ... }:
{
  environment.systemPackages = import ../../catalog/apps/claude-code.nix { inherit pkgs; };
}

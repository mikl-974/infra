{ pkgs, ... }:
{
  environment.systemPackages = import ../../catalog/apps/codex.nix { inherit pkgs; };
}
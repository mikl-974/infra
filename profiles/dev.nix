{ pkgs, ... }:
{
  imports = [
    ../modules/apps/editors.nix
    ../modules/apps/dev.nix
    ../modules/containers/podman.nix
  ];

  workstation.containers.podman.enable = true;

  environment.systemPackages = with pkgs; [
    git
    curl
    jq
  ];
}

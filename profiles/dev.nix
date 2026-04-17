{ pkgs, ... }:
{
  imports = [
    ./editors.nix
  ];

  environment.systemPackages = with pkgs; [
    git
    curl
    jq
  ];
}

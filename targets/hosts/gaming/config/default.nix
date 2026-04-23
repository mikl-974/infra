{ ... }:
{
  imports = [
    ../../../../modules/profiles/workstation-common.nix
    ../../../../modules/profiles/gaming.nix
    ./user.nix
  ];
}

{ ... }:
{
  imports = [
    ../../../../modules/profiles/workstation-common.nix
    ../../../../modules/profiles/dev.nix
    ./user.nix
  ];
}

# Noctalia Shell — official Home Manager integration.
# See https://docs.noctalia.dev/getting-started/nixos/
#
# This role wires the upstream Home Manager module and enables the shell.
# Per-user settings live in the user module and point to a JSON dotfile path.
{ inputs, ... }:
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia-shell = {
    enable = true;
  };
}

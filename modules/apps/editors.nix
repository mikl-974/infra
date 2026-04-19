{ pkgs, inputs, ... }:
let
  # Import the unstable nixpkgs input for newer editor packages (JetBrains IDEs).
  unstable = import inputs.nixpkgs { system = pkgs.stdenv.hostPlatform.system; };
in
{
  # Editors and IDEs are desktop applications — they are NOT part of the devShell.
  # The devShell provides the CLI/runtime environment; editors are separate tools
  # that work alongside it.
  #
  # This module is imported by profiles/dev.nix so that editors are available
  # on any host that opts into the dev profile.
  # Install editors from nixpkgs-unstable to get recent IDE releases
  environment.systemPackages = with unstable; [
    vscode
    jetbrains.rider
    jetbrains.webstorm
  ];
}

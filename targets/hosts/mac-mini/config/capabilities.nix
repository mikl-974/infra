{ pkgs, ... }:
{
  # Host-local capability map for `mac-mini`.
  #
  # This file is the authoritative place to answer:
  # "What does this machine have?"
  imports = [
    ../../../../systems/apps/ollama-darwin.nix
    ./nix-apps.nix
    ./casks.nix
    ./mas-apps.nix
  ];

  homelab.services.ollamaDarwin = {
    enable = true;
    # nixpkgs ollama requires the Xcode Metal toolchain to compile MLX.
    # Use the Homebrew cask binary (pre-built, no toolchain required).
    package = pkgs.runCommand "ollama-homebrew" { } ''
      mkdir -p $out/bin
      ln -s /opt/homebrew/bin/ollama $out/bin/ollama
    '';
  };
}

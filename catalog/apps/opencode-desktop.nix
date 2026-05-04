{ pkgs }:
with pkgs; [
  bun
  opencode-desktop
]
++ import ./vibe-notion.nix { inherit pkgs; }

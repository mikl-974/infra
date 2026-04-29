{ pkgs }:
with pkgs; [
  wineWow64Packages.stableFull
  winetricks
]

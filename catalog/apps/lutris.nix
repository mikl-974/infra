{ pkgs }:
with pkgs; [
  lutris
  wineWowPackages.staging
  winetricks
  vulkan-tools
  mesa-demos
]

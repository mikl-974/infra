{ pkgs }:
with pkgs; [
  lutris
  wineWow64Packages.staging
  winetricks
  vulkan-tools
  mesa-demos
]

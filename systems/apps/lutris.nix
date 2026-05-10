{ pkgs, ... }:
{
  environment.systemPackages = import ../../catalog/apps/lutris.nix { inherit pkgs; };

  # Lutris and downloaded Wine runners still assume FHS paths on NixOS.
  systemd.tmpfiles.rules = [
    "L+ /usr/bin/vulkaninfo - - - - ${pkgs.vulkan-tools}/bin/vulkaninfo"
    "L+ /lib/ld-linux.so.2 - - - - ${pkgs.pkgsi686Linux.glibc}/lib/ld-linux.so.2"
  ];
}

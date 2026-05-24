{ pkgs, ... }:
{
  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true;
  };

  virtualisation.spiceUSBRedirection.enable = true;

  environment.systemPackages = import ../../catalog/apps/virt-manager.nix { inherit pkgs; };
}

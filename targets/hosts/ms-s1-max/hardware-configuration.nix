{ config, lib, ... }:
{
  # Minimal hardware baseline captured from the current Fedora install.
  # Disk mounts come from `disko.nix`; keep this file focused on boot-critical
  # modules and firmware availability.
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];

  boot.kernelModules = [ "kvm-amd" ];

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}

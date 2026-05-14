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

  # Strix Halo needs large unified-memory limits for stable ROCm llama.cpp
  # workloads while still leaving a small reserve to the OS.
  boot.kernelParams = [
     "iommu=pt"
     "amdgpu.gttsize=92000"
     "ttm.pages_limit=32505856"
  ];

   hardware.enableRedistributableFirmware = true;
   hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

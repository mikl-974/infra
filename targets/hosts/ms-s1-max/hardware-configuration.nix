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
    "amd_iommu=off"               # Améliore grandement la stabilité et gagne ~10% de vitesse
    "amdgpu.gttsize=126976"        # Fixe la mémoire unifiée max à 124 Go
    "ttm.pages_limit=32505856"     # Obligatoire pour mapper >64 Go de RAM sur le GPU
  ];

   hardware.enableRedistributableFirmware = true;
   hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

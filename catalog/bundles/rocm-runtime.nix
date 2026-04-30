{ pkgs }:
with pkgs.rocmPackages; [
  clr
  rocm-runtime
  rocminfo
  rocm-smi
  amdsmi
]

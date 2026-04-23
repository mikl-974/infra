# Machine-specific variables for host 'main'.
#
# Edit this file to configure this machine.
# No other file needs to be modified for installation.
#
# After editing, validate before installing:
#   nix run .#validate-install -- main
#
# To generate this file interactively:
#   nix run .#init-host -- main
{
  system   = "x86_64-linux";    # NixOS platform
  username = "mfo";            # primary interactive user of the main workstation
  hostname = "main";            # hostname — matches nixosConfigurations key in flake.nix
  disk     = "/dev/DEFINE_DISK"; # target disk for disko / NixOS Anywhere — resolve on the target with `lsblk` (e.g. /dev/nvme0n1)
  timezone = "Asia/Bangkok";    # see: timedatectl list-timezones
  locale   = "en_US.UTF-8";    # system locale
}

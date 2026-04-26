# Disk layout for `ms-s1-max` — single NVMe workstation install.
#
# The device is read from `targets/hosts/ms-s1-max/vars.nix` so the layout can
# stay stable even if the machine is reinstalled later.
{ hostVars, ... }:
{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = hostVars.disk;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}

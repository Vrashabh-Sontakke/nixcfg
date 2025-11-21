{
  disko.devices = {
    disk = {
      main = {
        type    = "disk";
        device  = "/dev/nvme0n1";
        content = {
          type       = "gpt";
          partitions = {
            ESP = {
              name    = "ESP";
              label   = "Boot";
              size    = "1024M";
              type    = "EF00";
              content = {
                type         = "filesystem";
                format       = "vfat";
                mountpoint   = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            NixOS = {
              name    = "nixos";
              label   = "nixos";
              size    = "100G";
              content = {
                type       = "btrfs";
                extraArgs  = [ "-L" "nixos" "-f" ];
                subvolumes = {
                  "/root" = {
                    mountpoint   = "/";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "/home" = {
                    mountpoint   = "/home";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "/home/vrash" = { };
                  "/nix"  = {
                    mountpoint   = "/nix";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "/persist" = {
                    mountpoint = "/persist";
                    mountOptions = [ "compress=zstd" "noatime"];
                  };
                  "/log" = {
                    mountpoint = "/var/log";
                    mountOptions = [ "compress=zstd" "noatime"];
                  };
                  "/swap" = {
                    mountpoint         = "/swap";
                    swap.swapfile.size = "16G";
                  };
                };
              };
            };
            # Windows 11 dual boot
            Windows = {
              name    = "Windows";
              label   = "Windows";
              size    = "100%";
              type    = "0700"; # NTFS partition type code
              content = {
                type         = "filesystem";
                format       = "ntfs";
                mountOptions = [ "defaults" ];
              };
            };
          };
        };
      };
    };
  };
  fileSystems."/persist".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;
}

{ self, inputs, ... }: {
  
  flake.nixosModules.ZnyegHardware = { config, lib, pkgs, modulesPath, ... }:

  {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ ];
    boot.extraModulePackages = [ ];

    boot.kernelParams = [ "video=DP-1:1920x1080@144" "video=HDMI-A-1:1680x1050@60" ];

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/ae2ce549-230a-4d78-8f4f-e4e22bde1ef5";
        fsType = "ext4";
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/35F0-5447";
        fsType = "vfat";
         options = [ "fmask=0022" "dmask=0022" ];
      };

    swapDevices = [ ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
  
}

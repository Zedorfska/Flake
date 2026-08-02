{ self, ... }: {
  flake.nixosModules.amd = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.drivers.amd;
  in {
    options.device.features.drivers.amd.enable = lib.mkEnableOption "AMD GPU drivers";

    config = lib.mkIf cfg.enable {
      # Load the AMD driver early in the boot process
      boot.initrd.kernelModules = [ "amdgpu" ];
      
      # Use the amdgpu driver for Xorg (and Wayland dependencies)
      services.xserver.videoDrivers = [ "amdgpu" ];
      
      # Enable OpenGL/Vulkan and 32-bit support (for Steam/Wine)
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };
    };
  };
}

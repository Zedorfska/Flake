{ self, ... }: {
  flake.nixosModules.nvidia = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.drivers.nvidia;
  in {
    options.device.features.drivers.nvidia.enable = lib.mkEnableOption "NVIDIA drivers and Wayland fixes";

    config = lib.mkIf cfg.enable {
      boot.kernelParams = [ "nvidia-drm.modeset=1" "nvidia-drm.fbdev=1" ];
      
      services.xserver.videoDrivers = ["nvidia"];
      
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      hardware.nvidia = {
        modesetting.enable = true;
        open = false; 
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };

      environment.variables = {
        NIXOS_OZONE_WL = "1";
        LIBVA_DRIVER_NAME = "nvidia";
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        NVD_BACKEND = "direct";
      };
    };
  };
}

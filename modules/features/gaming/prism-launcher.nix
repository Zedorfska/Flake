{ self, ... }: {
  flake.nixosModules.prism = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.gaming.prism;
  in {
    options.device.features.gaming.prism.enable = lib.mkEnableOption "Prism Launcher (Minecraft)";

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [ 
        pkgs.prismlauncher

        pkgs.jdk8    # 1.12.2 and older
        pkgs.jdk17   # 1.17 to 1.20
        pkgs.jdk21   # 1.20.5+
      ];

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };
    };
  };
}

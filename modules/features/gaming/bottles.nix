{ self, ... }: {
  flake.nixosModules.bottles = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.gaming.bottles;
  in {
    options.device.features.gaming.bottles.enable = lib.mkEnableOption "Bottles";

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [ 
        pkgs.bottles
      ];
    };
  };
}

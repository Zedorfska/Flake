{ self, ... }: {
  flake.nixosModules.vintagestory = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.gaming.vintagestory;
  in {
    options.device.features.gaming.vintagestory.enable = lib.mkEnableOption "Videogame";

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [ 
        pkgs.vintagestory
      ];
    };
  };
}

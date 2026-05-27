{ self, ... }: {
  flake.nixosModules.wine = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.gaming.wine;
  in {
    options.device.features.gaming.wine.enable = lib.mkEnableOption "Wine";

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [ pkgs.wine ];
    };
  };
}

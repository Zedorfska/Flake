{ self, ... }: {
  flake.nixosModules.sunshine = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.software.sunshine;
  in {
    options.device.features.software.sunshine.enable = lib.mkEnableOption "Sunshine";

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [ pkgs.sunshine ];
    };
  };
}

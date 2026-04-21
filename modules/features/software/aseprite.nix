{ self, ... }: {
  flake.nixosModules.aseprite = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.software.aseprite;
    user = config.internal.username;
  in {
    options.device.features.software.aseprite.enable = lib.mkEnableOption "Aseprite";

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [ pkgs.aseprite ];
    };
  };
}

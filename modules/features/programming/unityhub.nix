{ self, ... }: {
  flake.nixosModules.unity = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.programming.unity;
  in
  {
    options.device.features.programming.unity.enable = lib.mkEnableOption "Unity Hub";

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [ pkgs.unityhub ];
    };
  };
}

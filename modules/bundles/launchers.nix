{ self, ... }: {
  flake.nixosModules.launchers-bundle = { config, lib, ... }: 
  let
    cfg = config.device.features.launchers.bundles.everything;
  in {
    imports = [
      self.nixosModules.wofi
    ];
    
    options.device.features.launchers.bundles.everything.enable = lib.mkEnableOption "Program launchers";

    config = lib.mkIf cfg.enable {
      device.features.launchers = {
        wofi.enable = lib.mkDefault true;
      };
    };
  };
}

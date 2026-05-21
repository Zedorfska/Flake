{ self, ... }: {
  flake.nixosModules.programming-bundle = { config, lib, ... }: 
  let
    cfg = config.device.features.programming.bundles.everything;
  in {
    imports = [
      self.nixosModules.rust
    ];
    
    options.device.features.programming.bundles.everything.enable = lib.mkEnableOption "Programming";

    config = lib.mkIf cfg.enable {
      device.features.programming = {
        rust.enable = lib.mkDefault true;
      };
    };
  };
}

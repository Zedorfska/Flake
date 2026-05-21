{ self, ... }: {
  flake.nixosModules.gaming-bundle = { config, lib, ... }: 
  let
    cfg = config.device.features.gaming.bundles.everything;
  in {
    imports = [
      self.nixosModules.steam
      self.nixosModules.prism
    ];
    
    options.device.features.gaming.bundles.everything.enable = lib.mkEnableOption "Launchers, etc.";

    config = lib.mkIf cfg.enable {
      device.features.gaming = {
        steam.enable = lib.mkDefault true;
        prism.enable = lib.mkDefault true;
      };
    };
  };
}

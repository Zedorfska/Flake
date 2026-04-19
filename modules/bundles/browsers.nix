{ self, ... }: {
  flake.nixosModules.browsers-bundle = { config, lib, ... }: 
  let
    cfg = config.device.features.browsers.bundles.everything;
  in {
    imports = [
      self.nixosModules.librewolf
      self.nixosModules.firefox
    ];
    
    options.device.features.browsers.bundles.everything.enable = lib.mkEnableOption "Browsers";

    config = lib.mkIf cfg.enable {
      device.features.browsers = {
        librewolf.enable = lib.mkDefault true;
        firefox.enable = lib.mkDefault true;
      };
    };
  };
}

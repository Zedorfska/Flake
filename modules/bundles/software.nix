{ self, ... }: {
  flake.nixosModules.software-bundle = { config, lib, ... }: 
  let
    cfg = config.device.features.software.bundles.everything;
  in {
    imports = [
      self.nixosModules.creative-bundle
      self.nixosModules.obsidian
    ];
    
    options.device.features.software.bundles.everything.enable = lib.mkEnableOption "All software";

    config = lib.mkIf cfg.enable {
      device.features.software = {
        bundles.creative.enable = lib.mkDefault true;
        obsidian.enable = lib.mkDefault true;
      };
    };
  };
}

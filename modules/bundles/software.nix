{ self, ... }: {
  flake.nixosModules.software-bundle = { config, lib, ... }: 
  let
    cfg = config.device.features.software.bundles.everything;
  in {
    imports = [
      self.nixosModules.aseprite
      self.nixosModules.creative-bundle
      self.nixosModules.obsidian
      self.nixosModules.blockbench
    ];
    
    options.device.features.software.bundles.everything.enable = lib.mkEnableOption "All software";

    config = lib.mkIf cfg.enable {
      device.features.software = {
        aseprite.enable = lib.mkDefault true;
        bundles.creative.enable = lib.mkDefault true;
        obsidian.enable = lib.mkDefault true;
        blockbench.enable = lib.mkDefault true;
      };
    };
  };
}

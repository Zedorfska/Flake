{ self, ... }: {
  flake.nixosModules.creative-bundle = { config, lib, ... }: 
  let
    cfg = config.device.features.software.bundles.creative;
  in {
    imports = [
      self.nixosModules.gimp
      self.nixosModules.inkscape
      self.nixosModules.kdenlive
      self.nixosModules.ardour
    ];
    
    options.device.features.software.bundles.creative.enable = lib.mkEnableOption "Creative Suite";

    config = lib.mkIf cfg.enable {
      device.features.software = {
        gimp.enable = lib.mkDefault true;
        inkscape.enable = lib.mkDefault true;
        kdenlive.enable = lib.mkDefault true;
        ardour.enable = lib.mkDefault true;
      };
    };
  };
}

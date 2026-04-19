{ self, ... }: {
  flake.nixosModules.filemanagers-bundle = { config, lib, ... }: 
  let
    cfg = config.device.features.filemanagers.bundles.everything;
  in {
    imports = [
      self.nixosModules.dolphin
    ];
    
    options.device.features.filemanagers.bundles.everything.enable = lib.mkEnableOption "File Managers";

    config = lib.mkIf cfg.enable {
      device.features.filemanagers = {
        dolphin.enable = lib.mkDefault true;
      };
    };
  };
}

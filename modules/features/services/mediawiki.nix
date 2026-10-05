{ self, ... }: {
  flake.nixosModules.mediawiki = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.services.mediawiki;
  in {
    options.device.features.services.hyprpolkitagent.enable = lib.mkEnableOption "Mediawiki";

    config = lib.mkIf cfg.enable {
      services.mediawiki.enable = true;
    };
  };
}

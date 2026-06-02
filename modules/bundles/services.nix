{ self, ... }: {
  flake.nixosModules.services-bundle = { config, lib, ... }: 
  let
    cfg = config.device.features.services.bundles.everything;
  in {
    imports = [
      self.nixosModules.dunst
      self.nixosModules.gpu-screen-recorder
      self.nixosModules.kanshi #
      #self.nixosModules.mpd
      self.nixosModules.pipewire
      self.nixosModules.swww #
      self.nixosModules.mpvpaper
      self.nixosModules.mprisence
    ];
    
    options.device.features.services.bundles.everything.enable = lib.mkEnableOption "Services";

    config = lib.mkIf cfg.enable {
      device.features.services = {
        dunst.enable = lib.mkDefault true;
        gpu-screen-recorder.enable = lib.mkDefault true;
        kanshi.enable = lib.mkDefault true; #
        #mpd.enable = lib.mkDefault true;
        pipewire.enable = lib.mkDefault true;
        swww.enable = lib.mkDefault true; #
        mpvpaper.enable = lib.mkDefault true; #
        mprisence.enable = lib.mkDefault true;
      };
    };
  };
}

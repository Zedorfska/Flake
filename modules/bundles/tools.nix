{ self, ... }: {
  flake.nixosModules.tools-bundle = { config, lib, ... }: 
  let
    cfg = config.device.features.tools.bundles.everything;
  in {
    imports = [
      self.nixosModules.ffmpeg
      self.nixosModules.hyprshot
      self.nixosModules.portals
      self.nixosModules.mpv
      self.nixosModules.qemu
    ];
    
    options.device.features.tools.bundles.everything.enable = lib.mkEnableOption "Tools";

    config = lib.mkIf cfg.enable {
      device.features.tools = {
        ffmpeg.enable = lib.mkDefault true;
        hyprshot.enable = lib.mkDefault true;
        portals.enable = lib.mkDefault true;
        mpv.enable = lib.mkDefault true;
        qemu.enable = lib.mkDefault true;
      };
    };
  };
}

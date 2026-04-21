{ self, ... }: {
  flake.nixosModules.cli-bundle = { config, lib, ... }: 
  let
    cfg = config.device.features.cli.bundles.everything;
  in {
    imports = [
      self.nixosModules.fastfetch
      self.nixosModules.cli-base
      self.nixosModules.rmpc
      self.nixosModules.tty-clock
      self.nixosModules.nvf
      self.nixosModules.yt-dlp
    ];
    
    options.device.features.cli.bundles.everything.enable = lib.mkEnableOption "CLI tools";

    config = lib.mkIf cfg.enable {
      device.features.cli = {
        fastfetch.enable = lib.mkDefault true;
        base.enable = lib.mkDefault true;
        rmpc.enable = lib.mkDefault true;
        tty-clock.enable = lib.mkDefault true;
        nvf.enable = lib.mkDefault true;
        yt-dlp.enable = lib.mkDefault true;
      };
    };
  };
}

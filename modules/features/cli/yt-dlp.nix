{ self, ... }: {
  flake.nixosModules.yt-dlp = { config, lib, pkgs, ... }:
  let
    cfg = config.device.features.cli.yt-dlp;
    user = config.internal.username;
  in {
    options.device.features.cli.yt-dlp = {
      enable = lib.mkEnableOption "yt-dlp via Home Manager";
    };

    config = lib.mkIf cfg.enable {
      home-manager.users.${user} = {
        programs.yt-dlp.enable = true;
      };
    };
  };
}

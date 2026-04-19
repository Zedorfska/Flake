{ self, ... }: {
  flake.nixosModules.ffmpeg = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.tools.ffmpeg;
  in {
    options.device.features.tools.ffmpeg.enable = lib.mkEnableOption "FFmpeg multimedia framework";

    config = lib.mkIf cfg.enable {
      home-manager.users.${config.internal.username} = {
        home.packages = with pkgs; [
          ffmpeg-full
        ];
      };
    };
  };
}

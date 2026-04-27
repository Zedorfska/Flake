{ self, ... }: {
  flake.nixosModules.mpvpaper = { config, lib, pkgs, ... }:
  let
    cfg = config.device.features.services.mpvpaper;
    user = config.internal.username;
    wallpaperPath = self.assets.wallpapers.scav; # Change wallpaper - TODO: make declarative per sys
  in {
    options.device.features.services.mpvpaper = {
      enable = lib.mkEnableOption "MPVPaper";
    };

    config = lib.mkIf cfg.enable {
      device.features.tools.mpv.enable = true;
      environment.systemPackages = [ pkgs.mpvpaper ];

      home-manager.users.${user} = {
        systemd.user.services.mpvpaper = {
          Unit = {
            Description = "MPVPaper service";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };
          Service = {
            #ExecStart = "${pkgs.mpvpaper}/bin/mpvpaper -o \"--hwdec=auto --vo=gpu --loop --no-audio\" '*' ${wallpaperPath}";
            ExecStart = "${pkgs.mpvpaper}/bin/mpvpaper -o \"--hwdec=auto --vo=gpu --loop --no-audio --cache=no --demuxer-max-bytes=1MiB --demuxer-max-back-bytes=1MiB --vd-lavc-dr=no\" '*' ${wallpaperPath}";
            Restart = "on-failure";
          };
          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
        };
      };
    };
  };
}

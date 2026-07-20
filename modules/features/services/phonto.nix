{ self, inputs, ... }: {
  flake.nixosModules.phonto = { config, lib, pkgs, ... }:
  let
    cfg = config.device.features.services.phonto;
    user = config.internal.username;
    wallpaperPath = self.assets.wallpapers.scavWebm;
    phontoPackage = inputs.phonto.packages.${pkgs.system}.default;
  in {
    options.device.features.services.phonto = {
      enable = lib.mkEnableOption "Phonto";
    };
    config = lib.mkIf cfg.enable {
      environment.systemPackages = with pkgs.gst_all_1; [
        gstreamer
        gst-plugins-base
        gst-plugins-good
        gst-plugins-bad
        gst-plugins-ugly
        #gst-vaapi
      ];
      home-manager.users.${user} = {
        systemd.user.services.phonto = {
          Unit = {
            Description = "Phonto video wallpaper";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };
          Service = {
            ExecStart = "${phontoPackage}/bin/phonto ${wallpaperPath}";
            Restart = "on-failure";
            Environment = [
              "GST_PLUGIN_PATH=${pkgs.gst_all_1.gst-plugins-base}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-good}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-bad}/lib/gstreamer-1.0:${pkgs.gst_all_1.gst-plugins-ugly}/lib/gstreamer-1.0"
            ];
          };
          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
        };
      };
    };
  };
}

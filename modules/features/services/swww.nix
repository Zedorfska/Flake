{ self, ... }: {
  flake.nixosModules.swww = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.services.swww;
    user = config.internal.username;
  in {
    options.device.features.services.swww.enable = lib.mkEnableOption "swww wallpaper daemon";

    config = lib.mkIf cfg.enable {
      home-manager.users.${user} = {
        home.packages = [ pkgs.swww ];

        systemd.user.services.swww = {
          Unit = {
            Description = "swww wallpaper daemon";
            PartOf = [ "graphical-session.target" ];
            After = [ "graphical-session.target" ];
          };

          Service = {
            Type = "simple";
            ExecStart = "${pkgs.swww}/bin/swww-daemon --format xrgb";
            
            ExecStartPost = "${pkgs.swww}/bin/swww img ${self.assets.wallpapers.default}";
            
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

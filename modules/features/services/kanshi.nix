{ self, ... }: { # TODO: Per system config
  flake.nixosModules.kanshi = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.services.kanshi;
    user = config.internal.username;
  in {
    options.device.features.services.kanshi.enable = lib.mkEnableOption "Kanshi display autoconfig";

    config = lib.mkIf cfg.enable {
      home-manager.users.${user} = {
        services.kanshi = {
          enable = true;
          systemdTarget = "graphical-session.target";

          settings = [
            {
              profile = {
                name = "default";
                outputs = [
                  {
                    criteria = "DP-1";
                    mode = "1920x1080@143.85";
                    position = "0,0";
                    status = "enable";
                  }
                  {
                    criteria = "HDMI-A-1";
                    mode = "1680x1050@59.88";
                    position = "1920,15";
                    status = "enable";
                  }
                ];
              };
            }
          ];
        };

        wayland.windowManager.hyprland.settings = { # FUUUUUUUCK
          monitor = [
            "DP-1,1920x1080@144,0x0,1"
            "HDMI-A-1,preferred,1920x15,1"
          ];
          xwayland = {
            force_zero_scaling = true;
          };
          xwaylandprimaryoutput = "DP-1";
          exec-once = [
            "${pkgs.xorg.xrandr}/bin/xrandr --output DP-1 --primary"
          ];
        };
      };
    };
  };
}

{ self, ... }: {
  flake.nixosModules.mpd = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.services.mpd;
    user = config.internal.username;
  in {
    options.device.features.services.mpd.enable = lib.mkEnableOption "Music Player Daemon";

    config = lib.mkIf cfg.enable {
      home-manager.users.${user} = {
        services.mpd = {
          enable = true;
          musicDirectory = "/home/${user}/Music";
          extraConfig = ''
            audio_output {
              type "pipewire"
              name "PipeWire Output"
            }
          '';
        };
      };

      environment.systemPackages = [ pkgs.mpc ];
    };
  };
}

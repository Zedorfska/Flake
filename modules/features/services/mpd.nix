{ self, ... }: {
  flake.nixosModules.mpd = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.services.mpd;
    user = config.internal.username;
  in {
    options.device.features.services.mpd = {
      enable = lib.mkEnableOption "Music Player Daemon";
      musicDirectory = lib.mkOption {
        type = lib.types.str;
        default = "/home/${user}/Music";
        description = "Music dir";
      };
    };

    config = lib.mkIf cfg.enable {
      home-manager.users.${user} = {
        services.mpd = {
          enable = true;
          musicDirectory = cfg.musicDirectory;
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

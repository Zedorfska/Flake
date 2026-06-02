{ self, ... }: {
  flake.nixosModules.mprisence = { config, lib, pkgs, ... }:
  let
    cfg  = config.device.features.services.mprisence;
    user = config.internal.username;
  in {
    options.device.features.services.mprisence.enable =
      lib.mkEnableOption "mprisence Discord Rich Presence for MPRIS";

    config = lib.mkIf cfg.enable {
      home-manager.users.${user} = {
        home.packages = [ pkgs.mprisence pkgs.mpd-mpris ];

        systemd.user.services.mprisence = {
          Unit = {
            Description = "mprisence Discord Rich Presence";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };
          Service = {
            ExecStart = "${pkgs.mprisence}/bin/mprisence";
            Restart = "on-failure";
            RestartSec = 5;
          };
          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
        };

        systemd.user.services.mpd-mpris = {
          Unit = {
            Description = "MPD MPRIS bridge";
            After = [ "mpd.service" ];
            PartOf = [ "graphical-session.target" ];
          };
          Service = {
            ExecStart = "${pkgs.mpd-mpris}/bin/mpd-mpris";
            Restart = "on-failure";
            RestartSec = 5;
          };
          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
        };

        xdg.configFile."mprisence/config.toml".text = ''
          clear_on_pause = true
          interval = 2000
          allowed_players = []

          [template]
          details = "{{{title}}}"
          state = "{{{artist_display}}}"
          large_text = "{{#if album}}{{{album}}}{{#if year}} ({{{year}}}){{/if}}{{/if}}"
          small_text = "{{#if player}}{{{player}}}{{else}}MPRIS{{/if}}"

          [activity_type]
          use_content_type = true
          default = "listening"

          [time]
          show = true
          as_elapsed = true

          [cover]
          file_names = ["cover", "folder", "front", "album", "art"]
          local_search_depth = 2

          [cover.provider]
          provider = ["musicbrainz", "catbox"]

          [cover.provider.musicbrainz]
          min_score = 95

          [cover.provider.catbox]
          use_litter = false

          [player]
          default = { ignore = false, app_id = "1121632048155742288", icon = "https://raw.githubusercontent.com/lazykern/mprisence/main/assets/icon.png", show_icon = false, allow_streaming = false, status_display_type = "details" }

          [player.mpd]
          app_id = "1126153268486213672"
          icon = "https://www.musicpd.org/logo.png"
          show_icon = true
        '';
      };
    };
  };
}

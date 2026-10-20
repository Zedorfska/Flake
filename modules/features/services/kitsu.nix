{ self, inputs, ... }: {
  flake.nixosModules.kitsu = { config, lib, pkgs, ... }:
    let
      cfg = config.device.features.services.kitsu;
      kitsuPkgs = inputs.kitsu.packages.${pkgs.stdenv.hostPlatform.system};

      domain = "slop.beton.gay";
      envFile = "/var/lib/zou/zou.env"; # SECRET_KEY=... and DB_PASSWORD=...

      # gunicorn must run inside a Python environment that contains Zou and all
      # of its dependencies, so it is started as `python -m gunicorn`.
      zouPython = pkgs.python3.withPackages (ps: [ (ps.toPythonModule kitsuPkgs.zou) ]);

      unit = {
        requires = [ "postgresql.service" "redis-zou.service" ];
        after = [ "postgresql.service" "redis-zou.service" ];
        path = [ pkgs.ffmpeg ];
        environment = {
          DB_USERNAME = "zou";
          DB_DATABASE = "zou";
          PREVIEW_FOLDER = "/var/lib/zou/previews";
          TMP_DIR = "/var/lib/zou/tmp";
          DOMAIN_NAME = domain;
        };
      };

      serviceConfig = {
        User = "zou";
        Group = "zou";
        EnvironmentFile = envFile;
      };
    in {
      options.device.features.services.kitsu.enable =
        lib.mkEnableOption "Kitsu";

      config = lib.mkIf cfg.enable {
        users.users.zou = { isSystemUser = true; group = "zou"; };
        users.groups.zou = { };

        services.postgresql = {
          enable = true;
          ensureDatabases = [ "zou" ];
          ensureUsers = [{ name = "zou"; ensureDBOwnership = true; }];
        };

        services.redis.servers.zou = {
          enable = true;
          port = 6379;
          bind = "127.0.0.1";
        };

        systemd.services.zou = unit // {
          description = "Zou (Kitsu API)";
          serviceConfig = serviceConfig // {
            ExecStart = "${zouPython}/bin/python -m gunicorn --bind 127.0.0.1:5000 --workers 3 --worker-class gevent zou.app:app";
            Restart = "on-failure";
          };
        };

        systemd.services.zou-events = unit // {
          description = "Zou event stream";
          serviceConfig = serviceConfig // {
            ExecStart = "${zouPython}/bin/python -m gunicorn --bind 127.0.0.1:5001 --workers 1 --worker-class geventwebsocket.gunicorn.workers.GeventWebSocketWorker zou.event_stream:app";
            Restart = "on-failure";
          };
        };

        systemd.services.zou-init = unit // {
          description = "Zou first-run database setup";
          serviceConfig = serviceConfig // {
            Type = "oneshot";
            ExecStart = [
              "${kitsuPkgs.zou}/bin/zou init-db"
              "${kitsuPkgs.zou}/bin/zou init-data"
            ];
          };
        };

        environment.systemPackages = [ kitsuPkgs.zou ];

        services.caddy = {
          enable = true;
          virtualHosts.${domain}.extraConfig = ''
            handle_path /api/* {
              reverse_proxy 127.0.0.1:5000
            }
            handle /socket.io/* {
              reverse_proxy 127.0.0.1:5001
            }
            handle {
              root * ${kitsuPkgs.kitsu}
              try_files {path} /index.html
              file_server
            }
          '';
        };

        # `systemctl start zou zou-events caddy`.
        systemd.services.postgresql.wantedBy = lib.mkForce [ ];
        systemd.services.redis-zou.wantedBy = lib.mkForce [ ];
        systemd.services.caddy.wantedBy = lib.mkForce [ ];

        networking.firewall.allowedTCPPorts = [ 80 443 ];

        systemd.tmpfiles.rules = [
          "d /var/lib/zou 0750 zou zou -"
          "d /var/lib/zou/previews 0750 zou zou -"
          "d /var/lib/zou/tmp 0750 zou zou -"
        ];
      };
    };
}

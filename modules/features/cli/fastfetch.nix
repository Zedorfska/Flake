{ self, ... }: {
  flake.nixosModules.fastfetch = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.cli.fastfetch;
    user = config.internal.username;
  in
  {
    options.device.features.cli.fastfetch.enable = lib.mkEnableOption "Fastfetch System Info" // {
      default = true;
    };

    config = lib.mkIf cfg.enable {
      home-manager.users.${user} = {
        home.packages = [ pkgs.fastfetch ];

        xdg.configFile."fastfetch/config.jsonc".text = ''
          {
            "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
            "logo": {
                "type": "auto",
                "padding": {
                    "top": 0,
                    "left": 1,
                    "right": 4
                }
            },
            "modules": [
              "title",
              "separator",
              "os",
              "host",
              "kernel",
              "uptime",
              "packages",
              "shell",
              "display",
              "de",
              "wm",
              "gpu",
              "cpu",
              "memory",
              "disk",
              "localip",
              /*"terminal",*/
              "break",
              "colors"
            ]
          }
        '';

        # TODO: add shells later
        programs.bash.shellAliases = {
          fetch = "fastfetch";
        };
      };
    };
  };
}

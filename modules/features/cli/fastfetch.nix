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
            "general": {
              "detectVersion": false,
              "dsForceDrm": true
            },
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
              {
                "type": "os",
                "format": "{pretty-name}"
              },
              /*"host",*/
              "kernel",
              /*"uptime",*/
              /*"packages",*/
              {
                "type": "shell",
                "format": "{pretty-name}"
              },
              /*{
                "type": "display",
                "format": "{width}x{height} @ {refresh-rate}Hz"
              },*/
              /*"de",*/
              {
                "type": "wm",
                "detectPlugin": false,
                "format": "{pretty-name}"
              },
              {
                "type": "gpu",
                "format": "{name}"
              },
              {
                "type": "cpu",
                "format": "{name} ({cores-logical}) @ {freq-max}"
              },
              {
                "type": "memory",
                "format": "{used} / {total} ({percentage})"
              },
              {
                "type": "disk",
                "key": "{mountpoint}",
                "format": "{size-used} / {size-total} ({size-percentage})"
              },
              {
                "type": "localip",
                "format": "{ipv4}"
              },
              /*{
                "type": "publicip",
                "format": "{ip}"
              },*/
              "terminal",
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

{ self, ... }: {
  flake.nixosModules.wofi = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.launchers.wofi;
    user = config.internal.username;
  in {
    options.device.features.launchers.wofi.enable = lib.mkEnableOption "Wofi Launcher";

    config = lib.mkIf cfg.enable {
      home-manager.users.${user} = {
        programs.wofi = {
          enable = true;
          settings = {
            show = "drun";
            width = 400;
            height = 300;
            always_parse_args = true;
            show_all = false;
            term = "kitty";
            hide_scroll = true;
            print_command = true;
            insensitive = true;
          };
          
          # style = ''
          #   window {
          #     margin: 0px;
          #     border: 1px solid #color;
          #     background-color: #color;
          #   }
          # '';
        };
      };
    };
  };
}

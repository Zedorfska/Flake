{ self, ... }: {
  flake.nixosModules.foot = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.terminals.foot;
    user = config.internal.username;
  in {
    options.device.features.terminals.foot.enable = lib.mkEnableOption "Foot terminal emulator";

    config = lib.mkIf cfg.enable {
      home-manager.users.${user} = {
        programs.foot = {
          enable = true;
          settings = {
            main = {
              term = "xterm-256color";
              font = "Geist Mono:size=11:style=Medium";
              font-bold = "Geist Mono:size=11:style=Bold";
              font-italic = "Geist Mono:size=11:style=Italic";
              font-bold-italic = "Geist Mono:size=11:style=Bold Italic";
              pad = "12x12"; # A little breathing room for the minimalist look
            };

            scrollback = {
              lines = 10000;
            };

            url = {
              launch = "${pkgs.xdg-utils}/bin/xdg-open \${url}";
              label-letters = "sadfjklewcmpgh";
              osc8-underline = "always";
            };

            cursor = {
              style = "block";
              blink = "yes";
            };

            mouse = {
              hide-when-typing = "yes";
            };

            colors = {
              alpha = "0.75";
            };

            bell = {
              urgent = "no";
              notify = "no";
            };
          };
        };
      };
    };
  };
}

{ lib, ... }: 
let
  m = "SUPER";
  sh = "SHIFT";
  ctrl = "CONTROL";
  alt = "ALT";
in {
  flake.nixosModules.twm = { config, lib, ... }: {
    
    options.device.twm = lib.mkOption {
      type = lib.types.submodule {
        options = {
          defaults = lib.mkOption { type = lib.types.attrsOf lib.types.anything; default = {}; };
          keybinds = lib.mkOption { type = lib.types.attrsOf lib.types.anything; default = {}; };
        };
      };
      default = {};
    };

    config.device.twm = {
      defaults = {
        terminal = "kitty";
        menu = "wofi --show drun";
        file_manager = "dolphin";
        screenshot = "hyprshot -m region --clipboard-only";
      };

      keybinds = {
        mod = m;
        moveMod = sh;
        resizeMod = ctrl;
        swapMod = alt;

        directions = {
          up = "up"; down = "down"; left = "left"; right = "right";
        };

        apps = {
          terminal     = { mod1 = m; key = "C"; };
          menu         = { mod1 = m; key = "R"; };
          file_manager = { mod1 = m; key = "E"; };
          screenshot   = { mod1 = m; mod2 = sh; key = "S"; };
        };

        workspaces = {
          ws1 = "1"; ws2 = "2"; ws3 = "3"; ws4 = "4"; ws5 = "5";
          ws6 = "6"; ws7 = "7"; ws8 = "8"; ws9 = "9"; ws10 = "D";
          sc1 = "A";
        };
      };
    };
  };
}

{ self, ... }: {
  flake.nixosModules.niri = { config, lib, pkgs, ... }:
  let
    cfg  = config.device.features.environments.niri;
    user = config.internal.username;
    t    = config.device.twm;
    k    = t.keybinds;
    d    = t.defaults;
    xkb  = config.services.xserver.xkb;

    # formatting
    cap  = s: lib.toUpper (lib.substring 0 1 s) + lib.toLower (lib.substring 1 (-1) s);
    mod  = cap k.mod;
    move = cap k.moveMod;

    mkWs = i: let key = k.workspaces."ws${toString i}"; n = toString i; in ''
      ${mod}+${key} { focus-workspace ${n}; }
      ${mod}+${move}+${key} { move-column-to-workspace ${n}; }
    '';

    niriKdl = ''
      input {
        keyboard {
          xkb {
            layout "${xkb.layout}"
            options "${xkb.options}"
          }
        }
        mouse {
          accel-profile "flat"
        }
      }

      binds {
        ${mod}+${k.apps.terminal.key}     { spawn-sh "${d.terminal}"; }
        ${mod}+${k.apps.menu.key}         { spawn-sh "${d.menu}"; }
        ${mod}+${k.apps.file_manager.key} { spawn-sh "${d.file_manager}"; }

        ${mod}+Q { close-window; }
        ${mod}+Shift+E { quit; }

        ${mod}+Left  { focus-column-left; }
        ${mod}+Right { focus-column-right; }
        ${mod}+Up    { focus-window-up; }
        ${mod}+Down  { focus-window-down; }

        ${mod}+${move}+Left  { move-column-left; }
        ${mod}+${move}+Right { move-column-right; }

        ${lib.concatMapStrings mkWs (lib.range 1 10)}
      }
    '';
  in {
    options.device.features.environments.niri.enable =
      lib.mkEnableOption "Niri scrollable-tiling Wayland compositor";

    config = lib.mkIf cfg.enable {
      programs.niri.enable = true;
      home-manager.users.${user}.home.file.".config/niri/config.kdl".text = niriKdl;
    };
  };
}

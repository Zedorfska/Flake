{ self, ... }: {
  flake.nixosModules.hyprland = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.environments.hyprland;
    user = config.internal.username;
    
    t = config.device.twm;
    k = t.keybinds;
    d = t.defaults;

    # HELPER: A simpler binder for Hyprland's CSV-style syntax
    # Usage: mkBind "MOD SHIFT" "KEY" "ACTION"
    mkBind = mods: key: action: "${mods}, ${key}, ${action}";

    # MAPPER: Automated directions (Focus, Move, Swap, Resize)
    # This turns your 4 directions * 4 actions into a concise loop.
    directionBinds = let
      hyprDir = { up = "u"; down = "d"; left = "l"; right = "r"; };
      resVal = { 
        up    = "0 -100"; 
        down  = "0 100"; 
        left  = "-100 0"; 
        right = "100 0"; 
      };
    in lib.concatMap (name: [
      (mkBind k.mod k.directions.${name} "movefocus, ${hyprDir.${name}}")
      (mkBind "${k.mod} ${k.moveMod}" k.directions.${name} "movewindow, ${hyprDir.${name}}")
      (mkBind "${k.mod} ${k.swapMod}" k.directions.${name} "swapwindow, ${hyprDir.${name}}")
      (mkBind "${k.mod} ${k.resizeMod}" k.directions.${name} "resizeactive, ${resVal.${name}}")
    ]) [ "up" "down" "left" "right" ];

    # MAPPER: Automated Workspaces
    # This generates binds for ws1-10 and the "Move to" variants
    workspaceBinds = lib.concatMap (n: let 
      ws = k.workspaces."ws${n}"; 
    in [
      (mkBind k.mod ws "workspace, ${n}")
      (mkBind "${k.mod} ${k.moveMod}" ws "movetoworkspace, ${n}")
    ]) (map toString (lib.range 1 10));

  in {
    imports = [
      self.nixosModules.twm
    ];
    
    options.device.features.environments.hyprland.enable = lib.mkEnableOption "Hyprland Tiling Window Manager";

    config = lib.mkIf cfg.enable {
      programs.hyprland.enable = true;

      home-manager.users.${user} = {
        wayland.windowManager.hyprland = {
          enable = true;
          settings = {
            # Defined in twm.nix
            "$mod" = k.mod;

            bind = [
              # --- App Launches (Intent-based) ---
              (mkBind k.apps.terminal.mod1     k.apps.terminal.key     "exec, ${d.terminal}")
              (mkBind k.apps.menu.mod1         k.apps.menu.key         "exec, ${d.menu}")
              (mkBind k.apps.file_manager.mod1 k.apps.file_manager.key "exec, ${d.file_manager}")
              (mkBind "${k.apps.screenshot.mod1}_${k.apps.screenshot.mod2}" k.apps.screenshot.key "exec, ${d.screenshot}")

              # --- Essential Window Actions ---
              (mkBind k.mod "Q" "killactive,")
              (mkBind "${k.mod} SHIFT" "Q" "forcekillactive,")
              (mkBind k.mod "V" "togglefloating,")
              (mkBind k.mod "J" "togglesplit,")
              
              # --- Special Workspace (Magic) ---
              (mkBind k.mod k.workspaces.sc1 "togglespecialworkspace, Magic")
              (mkBind "${k.mod} SHIFT" k.workspaces.sc1 "movetoworkspace, special:Magic")
            ] 
            ++ directionBinds 
            ++ workspaceBinds;

            bindm = [
              "$mod, mouse:272, movewindow"
              "$mod, mouse:273, resizewindow"
            ];

            input = {
              kb_layout = config.services.xserver.xkb.layout;
              kb_options = config.services.xserver.xkb.options;
              accel_profile = "flat";
            };
            # (lib.mkIf (config.device.features.services.swww.enable) "swww-daemon")
          };
        };
      };
    };
  };
}

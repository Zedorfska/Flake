{ self, ... }: {
  flake.nixosModules.hyprland = { config, lib, pkgs, ... }:
  let
    cfg  = config.device.features.environments.hyprland;
    user = config.internal.username;
    t    = config.device.twm;
    k    = t.keybinds;
    d    = t.defaults;

    hyprlandLua = ''
      ---          ---
      --- MONITORS --- TODO: FUCKKKKKKKKKKKKKK
      ---          ---
      hl.monitor({
        output   = "DP-1",
        mode     = "1920x1080@143.85Hz",
        position = "0x0",
        scale    = "auto",
      })
      hl.monitor({
        output   = "HDMI-A-1",
        mode     = "preferred",
        position = "1920x15",
        scale    = "auto",
      })

      ---      ---
      --- VARS ---
      ---      ---
      local mod = "${k.mod}"

      local terminal    = "${d.terminal}"
      local menu        = "${d.menu}"
      local fileManager = "${d.file_manager}"
      local screenshot  = "${d.screenshot}"

      ---       ---
      --- INPUT ---
      ---       ---
      hl.config({
        input = {
          kb_layout  = "${config.services.xserver.xkb.layout}",
          kb_options = "${config.services.xserver.xkb.options}",
          accel_profile = "flat",
          follow_mouse = 1,
          sensitivity  = 0,
        },
      })

      ---           ---
      --- AUTOSTART ---
      ---           ---
      hl.on("hyprland.start", function()
        os.execute("systemctl --user import-environment HYPRLAND_INSTANCE_SIGNATURE WAYLAND_DISPLAY DISPLAY XAUTHORITY")
  os.execute("systemctl --user start graphical-session.target &")
      end)
      -- I am going to need someone to explain to me why on
      -- gods green earth do I have to add this line manually?
      -- I am irreparably angry

      ---          ---
      --- ENV VARS ---
      ---          ---

      ---          ---
      --- KEYBINDS ---
      ---          ---
      hl.bind(mod .. " + ${k.apps.terminal.key}",     hl.dsp.exec_cmd(terminal))
      hl.bind(mod .. " + ${k.apps.menu.key}",         hl.dsp.exec_cmd(menu))
      hl.bind(mod .. " + ${k.apps.file_manager.key}", hl.dsp.exec_cmd(fileManager))
      hl.bind(mod .. " + ${k.apps.screenshot.mod2} + ${k.apps.screenshot.key}", hl.dsp.exec_cmd(screenshot))

      hl.bind(mod .. " + Q", hl.dsp.window.close())
      hl.bind(mod .. " + SHIFT + Q", hl.dsp.window.kill())
      hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
      hl.bind(mod .. " + J", hl.dsp.layout("togglesplit"))

      local dirs = { up = "up", down = "down", left = "left", right = "right" }
      local resizeVals = {
        up    = { x = 0,    y = -100, relative = true },
        down  = { x = 0,    y = 100,  relative = true },
        left  = { x = -100, y = 0,    relative = true },
        right = { x = 100,  y = 0,    relative = true },
      }
      for dir, hlDir in pairs(dirs) do
        hl.bind(mod .. " + " .. dir,                   hl.dsp.focus({ direction = hlDir }))
        hl.bind(mod .. " + ${k.moveMod} + " .. dir,    hl.dsp.window.move({ direction = hlDir }))
        hl.bind(mod .. " + ${k.swapMod} + " .. dir,    hl.dsp.window.swap({ direction = hlDir }))
        hl.bind(mod .. " + ${k.resizeMod} + " .. dir, hl.dsp.window.resize(resizeVals[dir]))
      end

      for i = 1, 9 do
        local key = i % 10
        hl.bind(mod .. " + " .. key,                   hl.dsp.focus({ workspace = i }))
        hl.bind(mod .. " + ${k.moveMod} + " .. key,    hl.dsp.window.move({ workspace = i }))
      end
      hl.bind(mod .. " + D",                hl.dsp.focus({ workspace = 10 }))
      hl.bind(mod .. " + ${k.moveMod} + D", hl.dsp.window.move({ workspace = 10 }))

      hl.bind(mod .. " + ${k.workspaces.sc1}",         hl.dsp.workspace.toggle_special("magic"))
      hl.bind(mod .. " + SHIFT + ${k.workspaces.sc1}", hl.dsp.window.move({ workspace = "special:magic" }))

      hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
      hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

      ---        ---
      --- VISUAL ---
      ---        ---

      ---            ---
      --- WORKSPACES ---
      ---            ---

      ---                                                             ---
      --- GO THREE UPDATES IN A ROW WITHOUT BREAKING MY CONFIGURATION ---
      ---                                                             ---
      hl.config({
        misc = {
          force_default_wallpaper = 0,
          disable_hyprland_logo   = true,
        },
      })
    '';
  in {
    imports = [ self.nixosModules.twm ];

    options.device.features.environments.hyprland.enable =
      lib.mkEnableOption "Hyprland Tiling Window Manager";
    config = lib.mkIf cfg.enable {
      programs.hyprland.enable = true;
      home-manager.users.${user} = {
  home.file.".config/hypr/hyprland.lua".text = hyprlandLua;
      };
    };
  };
}

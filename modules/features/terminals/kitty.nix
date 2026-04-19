{ self, ... }: {
  flake.nixosModules.kitty = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.terminals.kitty;
    user = config.internal.username;
  in {
    options.device.features.terminals.kitty.enable = lib.mkEnableOption "Kitty terminal emulator";

    config = lib.mkIf cfg.enable {
      home-manager.users.${user} = {
        programs.kitty = {
          enable = true;
          font = {
            name = "Geist Mono Medium";
            size = 11;
          };
          settings = {
            bold_font        = "Geist Mono Bold";
            italic_font      = "Geist Mono Italic";
            bold_italic_font = "Geist Mono Bold Italic";
            
            scrollback_lines = 10000;
            enable_audio_bell = false;
            update_check_interval = 0;
            background_opacity = "0.75";
            confirm_os_window_close = 0;
            
            symbol_map = "U+E000-U+E7C7,U+F000-U+F2E0 Symbols Nerd Font";
          };
        };
      };
    };
  };
}

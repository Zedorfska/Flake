{ self, ... }: {
  flake.nixosModules.theme = { pkgs, lib, config, ... }: 
  let
    cfg = config.device.features.themes.dark;
    user = config.internal.username;
  in {
    options.device.features.themes.dark.enable = lib.mkEnableOption "Desktop Theming (GTK/QT)";

    config = lib.mkIf cfg.enable {

      programs.bash.promptInit = ''
        PS1='\n\[\033[1;38;2;196;90;117m\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\$\[\033[0m\] '
      '';

      home-manager.users.${user} = {
        dconf.settings = {
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
          };
        };

        gtk = {
          enable = true;
          #gtk4.theme = config.gtk.theme;
          theme = {
            name = "adw-gtk3-dark";
            package = pkgs.adw-gtk3;
          };
          iconTheme = {
            name = "Papirus-Dark";
            package = pkgs.papirus-icon-theme;
          };
        };

        qt = {
          enable = true;
          platformTheme.name = "gtk3";
          style.name = "adwaita-dark";
        };

        home.sessionVariables = {
          GTK_THEME = "adw-gtk3-dark";
        };
      };
    };
  };
}

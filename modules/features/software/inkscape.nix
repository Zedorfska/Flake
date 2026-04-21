{ self, ... }: {
  flake.nixosModules.inkscape = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.software.inkscape;
    user = config.internal.username;
  in
  {
    options.device.features.software.inkscape.enable = lib.mkEnableOption "Inkscape Vector Editor";

    config = lib.mkIf cfg.enable {
      home-manager.users.${user} = {
        home.packages = [ pkgs.inkscape-with-extensions ];

        xdg.desktopEntries.inkscape = {
          name = "Inkscape";
          genericName = "Vector Graphics Editor";
          exec = "env GDK_BACKEND=x11 inkscape %F";
          icon = "org.inkscape.Inkscape";
          terminal = false;
          categories = [ "Graphics" "VectorGraphics" "2DGraphics" "GTK" ];
          mimeType = [ 
            "image/svg+xml" 
            "image/svg+xml-compressed" 
          ];
        };
      };
    };
  };
}

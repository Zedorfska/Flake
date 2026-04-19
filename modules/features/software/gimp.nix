{ self, ... }: {
  flake.nixosModules.gimp = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.software.gimp;
    user = config.internal.username;

    gimp-with-plugins = pkgs.gimp-with-plugins.override {
      plugins = with pkgs.gimpPlugins; [
        resynthesizer
        gmic
      ];
    };
  in
  {
    options.device.features.software.gimp.enable = lib.mkEnableOption "GIMP Image Editor";

    config = lib.mkIf cfg.enable {
      home-manager.users.${user} = {
        home.packages = [ gimp-with-plugins ];

        xdg.desktopEntries.gimp = {
          name = "GIMP";
          exec = "gimp %U";
          icon = "gimp";
          terminal = false;
          categories = [ "Graphics" "2DGraphics" "RasterGraphics" "GTK" ];
          mimeType = [ "image/png" "image/jpeg" "image/bmp" "image/x-xcf" ];
        };
      };
    };
  };
}

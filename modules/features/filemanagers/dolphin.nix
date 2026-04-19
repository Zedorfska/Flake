{ self, ... }: {
  flake.nixosModules.dolphin = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.filemanagers.dolphin;
    user = config.internal.username;
    
    activeThumbnails = if (cfg.thumbnails.enable) 
                       then [ pkgs.kdePackages.ffmpegthumbs ] 
                       else [];
  in {
    options.device.features.filemanagers.dolphin = {
      enable = lib.mkEnableOption "Dolphin File Manager";
      
      thumbnails = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable video thumbnails via FFmpeg";
        };
      };
    };

    config = lib.mkIf cfg.enable {
      programs.dconf.enable = true;

      home-manager.users.${user} = {
        home.packages = with pkgs; [
          kdePackages.dolphin
          kdePackages.kio-extras
          kdePackages.breeze-icons
        ] ++ activeThumbnails;
      };
    };
  };
}

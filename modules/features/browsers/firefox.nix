{ self, ... }: {
  flake.nixosModules.firefox = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.browsers.firefox;
    user = config.internal.username;
  in {
    options.device.features.browsers.firefox.enable = lib.mkEnableOption "Firefox Browser";

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [ pkgs.firefox ];

      home-manager.users.${user} = {
        programs.firefox = {
          enable = true;
        };

#        home.file.".librewolf/${user}/chrome/userContent.css" = {
#          text = ''
#            @font-face {
#              font-family: "neoletters";
#              src: local("neoletters");
#              unicode-range: U+F1900-U+F19FF;
#            }

#            * {
#              font-family: inherit, "neoletters" !important;
#            }
#         '';
#        };
      };
    };
  };
}

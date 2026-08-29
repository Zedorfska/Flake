{ self, lib, ... }: {
  config = {
    flake.nixosModules.primaryUser = { config, pkgs, lib, ... }: 
    {
      options.internal.username = lib.mkOption {
        type = lib.types.str;
        default = "Zvyezdana";
      };

      config = let
        name = config.internal.username;
      in {
        users.users.${name} = {
          isNormalUser = true;
          extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
          home = "/home/${name}";
        };

        home-manager = {

          useGlobalPkgs = true;
          useUserPackages = true;

          users.${name} = {
            # TODO: Move elsewhere
            xdg.mimeApps = {
              enable = true;
              defaultApplications = {
                "image/png"  = "mpv.desktop";
                "image/jpeg" = "mpv.desktop";
                "image/gif"  = "mpv.desktop";
                "image/webp" = "mpv.desktop";
              };
            };

            home.username = name;
            home.homeDirectory = "/home/${name}";
            home.stateVersion = "26.05";
          };
        };
      };
    };
  };
}

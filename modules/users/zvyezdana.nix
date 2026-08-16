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
          shell = pkgs.bash;
        };

        programs.bash.enable = true;

        home-manager = {
          
          useGlobalPkgs = true;
          useUserPackages = true;
          
          users.${name} = {
            home.username = name;
            home.homeDirectory = "/home/${name}";
            home.stateVersion = "26.05";
          };
        };
      };
    };
  };
}

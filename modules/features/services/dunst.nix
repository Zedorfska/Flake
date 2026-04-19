{ self, inputs, ... }: {
  flake.nixosModules.dunst = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.services.dunst;
    system = pkgs.stdenv.hostPlatform.system;
  in {
    options.device.features.services.dunst.enable = lib.mkEnableOption "Dunst notification daemon";

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [ 
        self.packages.${system}.dunst 
        pkgs.libnotify 
      ];
    };
  };

  perSystem = { pkgs, ... }: {
    packages.dunst = inputs.wrapper-modules.wrappers.dunst.wrap {
      inherit pkgs;
      settings = {
        global = {
          width = 300;
          height = 300;
          offset = "30x30";
          origin = "top-right";
          frame_color = "#89b4fa";
          font = "Sans 10";
        };

      };
    };
  };
}

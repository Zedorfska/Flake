{ self, inputs, ... }: {
  flake.nixosModules.niri = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.environments.niri;
    system = pkgs.stdenv.hostPlatform.system;
  in {
    options.device.features.environments.niri.enable = lib.mkEnableOption "Niri compositor";

    config = lib.mkIf cfg.enable {
      programs.niri = {
        enable = true;
        package = self.packages.${system}.niri;
      };
    };
  };

  perSystem = { pkgs, lib, ... }: {
    packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      settings = {
        input.keyboard.xkb.layout = "hr,rs";
        layout.gaps = 5;
        binds = {
          "Mod+C".spawn-sh = lib.getExe pkgs.kitty;
          "Mod+Q".close-window = null;
        };
      };
    };

    packages.default = self.packages.${pkgs.stdenv.hostPlatform.system}.niri;
  };
}

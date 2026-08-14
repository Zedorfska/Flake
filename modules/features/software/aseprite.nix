{ self, inputs, ... }: {
  flake.nixosModules.aseprite = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.software.aseprite;
    user = config.internal.username;
    asepritePkgs = import inputs.nixpkgs-aseprite {
      system = pkgs.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  in {
    options.device.features.software.aseprite.enable = lib.mkEnableOption "Aseprite";

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [ asepritePkgs.aseprite ];
    };
  };
}

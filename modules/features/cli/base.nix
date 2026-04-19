{ self, ... }: {
  flake.nixosModules.cli-base = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.cli.base;
  in {
    options.device.features.cli.base.enable = lib.mkEnableOption "Essential CLI tools" // {
      default = true;
    };

    config = lib.mkIf cfg.enable {
      environment.systemPackages = with pkgs; [
        tree
        git
        wget
        unzip
      ];
    };
  };
}

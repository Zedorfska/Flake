{ ... }: {
  flake.nixosModules.kdenlive = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.software.kdenlive;
    user = config.internal.username;
  in {
    options.device.features.software.kdenlive.enable = lib.mkEnableOption "Kdenlive";

    config = lib.mkIf cfg.enable {
      home-manager.users.${user}.home.packages = [ pkgs.kdePackages.kdenlive ];
    };
  };
}

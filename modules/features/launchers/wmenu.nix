{ self, ... }: {
  flake.nixosModules.wmenu = { config, lib, pkgs, ... }:
  let
    cfg = config.device.features.launchers.wmenu;
    user = config.internal.username;
  in {
    options.device.features.launchers.wmenu.enable = lib.mkEnableOption "wmenu";

    config = lib.mkIf cfg.enable {
      home-manager.users.${user} = {
        home.packages = [ pkgs.wmenu ];
      };
    };
  };
}

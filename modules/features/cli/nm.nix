{ self, ... }: {
  flake.nixosModules.networkmanager = { config, lib, pkgs, ... }:
  let
    cfg = config.device.features.cli.networkmanager;
    user = config.internal.username;
  in {
    options.device.features.cli.networkmanager = {
      enable = lib.mkEnableOption "Network Manager";
    };

    config = lib.mkIf cfg.enable {
      networking.networkmanager.enable = true;

      users.users.${user}.extraGroups = [ "networkmanager" ];
    };
  };
}

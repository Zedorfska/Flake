{ self, ... }: {
  flake.nixosModules.kdeconnect = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.software.kdeconnect;
  in {
    options.device.features.software.kdeconnect.enable = lib.mkEnableOption "KDEConnect";
    config = lib.mkIf cfg.enable {
      programs.kdeconnect.enable = true;
      device.features.cli.sshfs.enable = true;
    };
  };
}

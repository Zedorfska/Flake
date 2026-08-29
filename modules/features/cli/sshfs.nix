{ self, ... }: {
  flake.nixosModules.sshfs = { config, lib, pkgs, ... }:
  let
    cfg = config.device.features.cli.sshfs;
  in {
    options.device.features.cli.sshfs.enable = lib.mkEnableOption "SSHFS";

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [ pkgs.sshfs ];
    };
  };
}

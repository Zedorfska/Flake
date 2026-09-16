{ self, ... }: {
  flake.nixosModules.monero = { config, lib, pkgs, ... }:
  let
    cfg = config.device.features.cli.monero;
  in {
    options.device.features.cli.monero.enable = lib.mkEnableOption "Monero CLI";

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [ pkgs.monero-cli ];
    };
  };
}

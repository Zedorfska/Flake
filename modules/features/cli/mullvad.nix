{ self, ... }: {
  flake.nixosModules.mullvad = { config, lib, pkgs, ... }:
  let
    cfg = config.device.features.cli.mullvad;
  in {
    options.device.features.cli.mullvad.enable = lib.mkEnableOption "Mullvad";

    config = lib.mkIf cfg.enable {
      services.mullvad-vpn.enable = true;
    };
  };
}

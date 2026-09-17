{ self, ... }: {
  flake.nixosModules.tor = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.browsers.tor;
  in {
    options.device.features.browsers.tor.enable = lib.mkEnableOption "Tor";

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [ pkgs.tor ];
    };
  };
}

{ self, ... }: {
  flake.nixosModules.ciscopackettracer = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.software.ciscopackettracer;
  in {
    options.device.features.software.ciscopackettracer.enable = lib.mkEnableOption "Cisco Packet Tracer";

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [ pkgs.ciscopackettracer ];
    };
  };
}

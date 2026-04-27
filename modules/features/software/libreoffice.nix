{ self, ... }: {
  flake.nixosModules.libreoffice = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.software.libreoffice;
  in {
    options.device.features.software.libreoffice.enable = lib.mkEnableOption "Libreoffice";

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [ pkgs.libreoffice ];
    };
  };
}

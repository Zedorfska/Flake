{ self, ... }: {
  flake.nixosModules.hedgedoc = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.services.hedgedoc;
  in {
    options.device.features.services.hedgedoc.enable = lib.mkEnableOption "HedgeDoc";

    config = lib.mkIf cfg.enable {
      services.hedgedoc = {
        enable = true;

        settings = {
          host = "127.0.0.1";
          port = 3000;

          domain = "docs.beton.gay";
          protocolUseSSL = true;
          urlAddPort = false;

          allowAnonymous = false;
          allowEmailRegister = false;
          defaultPermission = "private";
        };
      };
      services.caddy = {
          enable = true;
          virtualHosts."docs.beton.gay".extraConfig = ''
            reverse_proxy 127.0.0.1:3000
          '';
        };
    };
  };
}

{ self, ... }: {
  flake.nixosModules.firefox = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.browsers.firefox;
    user = config.internal.username;
  in {
    options.device.features.browsers.firefox.enable = lib.mkEnableOption "Firefox Browser";

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [ pkgs.firefox ];

      home-manager.users.${user} = {
        programs.firefox = {
          enable = true;
        };
      };
    };
  };
}

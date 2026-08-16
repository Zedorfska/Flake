{ self, ... }: {
  flake.nixosModules.sunshine = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.software.sunshine;
    user = config.internal.username;
  in {
    options.device.features.software.sunshine.enable = lib.mkEnableOption "Sunshine";

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [ pkgs.sunshine ];

      home-manager.users.${user}.xdg.configFile."sunshine/sunshine.conf".text = ''
        address_family = ipv4
        mouse = disabled
      '';
    };
  };
}

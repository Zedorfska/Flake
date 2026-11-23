{ self, ... }: {
  flake.nixosModules.tiny = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.chat.tiny;
  in {
    options.device.features.chat.tiny.enable = lib.mkEnableOption "IRC Client";

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [ 
        pkgs.tiny
      ];
      home-manager.users.Zvyezdana.xdg.configFile."tiny/config.yml".text = ''
        servers:
          - addr: irc.zedorfska.net
            port: 6697
            tls: true
            realname: Zedorfska
            nicks: [Zedorfska]
            join:
              - "#lobby"

        defaults:
          nicks: [Zedorfska]
          realname: Zedorfska
          join: []
          tls: true
      '';
    };
  };
}

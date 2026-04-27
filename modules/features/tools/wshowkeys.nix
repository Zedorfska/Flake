{ self, ... }: {
  flake.nixosModules.wshowkeys = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.tools.wshowkeys;
  in {
    options.device.features.tools.wshowkeys.enable = lib.mkEnableOption "WSHOWKEYS";

    config = lib.mkIf cfg.enable {
      environment.systemPackages = with pkgs; [ 
        wshowkeys
      ];

      security.wrappers.wshowkeys = {
        source = "${pkgs.wshowkeys}/bin/wshowkeys";
        owner = "root";
        group = "root";
        setuid = true;
      };
    };
  };
}

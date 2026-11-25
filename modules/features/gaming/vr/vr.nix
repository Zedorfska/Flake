{ self, ... }: {
  flake.nixosModules.vr = { config, lib, pkgs, ... }:
  let
    cfg = config.device.features.gaming.vr;
  in {
    options.device.features.gaming.vr.enable = lib.mkEnableOption "VR";

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [
        pkgs.android-tools
        pkgs.wivrn
        pkgs.xrizer
        pkgs.wayvr
      ];

      services.avahi = {
        enable = true;
        publish = {
          enable = true;
          userServices = true;
        };
      };

      systemd.user.tmpfiles.rules = [
        "d %h/.config/wayvr/theme/gui 0755 - - -"
        "L+ %h/.config/wayvr/theme/gui/watch.xml - - - - ${./wayvr-watch.xml}"
      ];
    };
  };
}

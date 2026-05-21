{ self, ... }: {
  flake.nixosModules.portals = { config, lib, pkgs, ... }:
  let
    cfg = config.device.features.tools.portals;
  in {
    options.device.features.tools.portals = {
      enable = lib.mkEnableOption "I like to stream on Discord";
    };

    config = lib.mkIf cfg.enable {
      device.features.services.pipewire.enable = true;

      xdg.portal = {
        enable = true;
        extraPortals = [ 
          pkgs.xdg-desktop-portal-hyprland 
          pkgs.xdg-desktop-portal-gtk
        ];
        config = {
          hyprland = {
            default = [ "hyprland" "gtk" ];
            "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
            "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
          };
          common = {
            default = [ "gtk" ];
          };
        };
      };
    };
  };
}

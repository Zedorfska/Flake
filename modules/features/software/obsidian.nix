{ self, ... }: {
  flake.nixosModules.obsidian = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.software.obsidian;
  in {
    options.device.features.software.obsidian.enable = lib.mkEnableOption "Obsidian";

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [ pkgs.obsidian ];

      environment.variables = lib.mkIf (config.device.features.environments.hyprland.enable || config.device.features.environments.niri.enable) {
        NIXOS_OZONE_WL = "1";
      };
    };
  };
}

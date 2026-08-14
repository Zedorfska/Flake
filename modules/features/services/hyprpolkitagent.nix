{ self, ... }: {
  flake.nixosModules.hyprpolkitagent = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.services.hyprpolkitagent;
  in {
    options.device.features.services.hyprpolkitagent.enable = lib.mkEnableOption "Hyprland polkit";

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [ pkgs.hyprpolkitagent ];
    };
  };
}

{ self, ... }: {
  flake.nixosModules.hyprshot = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.tools.hyprshot;
  in {
    options.device.features.tools.hyprshot.enable = lib.mkEnableOption "Hyprshot screenshot tool";

    config = lib.mkIf cfg.enable {
      environment.systemPackages = with pkgs; [ 
        hyprshot
      ];
    };
  };
}

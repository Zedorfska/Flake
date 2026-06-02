{ self, ... }: {
  flake.nixosModules.environments-bundle = { config, lib, ... }:
  let
    cfg = config.device.features.environments.bundles.everything;
  in {
    imports = [
      self.nixosModules.twm

      self.nixosModules.hevel
      self.nixosModules.hyprland
      self.nixosModules.niri
      self.nixosModules.dwl
    ];
    
    options.device.features.environments.bundles.everything.enable = lib.mkEnableOption "DEs, WMs, etc.";

    config = lib.mkIf cfg.enable {
      device.features.environments = {
        hevel.enable = lib.mkDefault true;
        hyprland.enable = lib.mkDefault true;
        niri.enable = lib.mkDefault true;
        dwl.enable = lib.mkDefault true;
      };
    };
  };
}

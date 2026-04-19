{ self, ... }: {
  flake.nixosModules.terminals-bundle = { config, lib, ... }: 
  let
    cfg = config.device.features.terminals.bundles.everything;
  in {
    imports = [
      self.nixosModules.foot
      self.nixosModules.kitty
    ];
    
    options.device.features.terminals.bundles.everything.enable = lib.mkEnableOption "Terminals";

    config = lib.mkIf cfg.enable {
      device.features.terminals = {
        kitty.enable = lib.mkDefault true;
        foot.enable = lib.mkDefault true;
      };
    };
  };
}

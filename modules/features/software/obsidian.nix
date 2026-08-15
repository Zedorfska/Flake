{ self, ... }: {
  flake.nixosModules.obsidian = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.software.obsidian;
  in {
    options.device.features.software.obsidian.enable = lib.mkEnableOption "Obsidian";

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [ pkgs.obsidian ];
    };
  };
}

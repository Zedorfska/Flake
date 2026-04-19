{ self, ... }: {
  flake.nixosModules.steam = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.gaming.steam;
  in {
    options.device.features.gaming.steam.enable = lib.mkEnableOption "Steam and gaming optimizations";

    config = lib.mkIf cfg.enable {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true; 
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
      };

      programs.gamemode.enable = true;

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      hardware.steam-hardware.enable = true;

      environment.systemPackages = [ pkgs.gamescope ];
    };
  };
}

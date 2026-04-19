{ self, ... }: {
  flake.nixosModules.tty-clock = { config, lib, pkgs, ... }:
  let
    cfg = config.device.features.cli.tty-clock;
    user = config.internal.username;
  in {
    options.device.features.cli.tty-clock = {
      enable = lib.mkEnableOption "tty-clock";
      
      center = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to center the clock by default.";
      };

      twentyFour = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Use 24h time format.";
      };
    };

    config = lib.mkIf cfg.enable {
      environment.shellAliases = {
        clock = "tty-clock ${lib.optionalString cfg.center "-c"} ${lib.optionalString (!cfg.twentyFour) "-t"} -s -C 4";
      };

      environment.systemPackages = [ pkgs.tty-clock ];
    };
  };
}

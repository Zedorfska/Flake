{ self, ... }: {
  flake.nixosModules.bash = { config, lib, pkgs, ... }:
  let
    cfg = config.device.features.shells.bash;
    name = config.internal.username;
  in {
    options.device.features.shells.bash.enable = lib.mkEnableOption "bash";

    config = lib.mkIf cfg.enable {
      programs.bash.enable = true;
      users.users.${name}.shell = pkgs.bash;
    };
  };
}

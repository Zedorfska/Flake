{ self, ... }: {
  flake.nixosModules.gitui = { config, lib, pkgs, ... }:
  let
    cfg = config.device.features.cli.gitui;
    user = config.internal.username;
  in {
    options.device.features.cli.gitui.enable =
      lib.mkEnableOption "GitUI";
    config = lib.mkIf cfg.enable {
      home-manager.users.${user} = {
        home.packages = with pkgs; [ gitui ];
      };
    };
  };
}

{ self, ... }: {
  flake.nixosModules.godot = { config, lib, pkgs, ... }:
  let
    cfg = config.device.features.software.godot;
    user = config.internal.username;
  in {
    options.device.features.software.godot.enable =
      lib.mkEnableOption "Godot C#";
    config = lib.mkIf cfg.enable {
      home-manager.users.${user} = {
        home.packages = with pkgs; [
          godot-mono
          dotnet-sdk
        ];
      };
    };
  };
}

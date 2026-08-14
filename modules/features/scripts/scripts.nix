{ self, ... }: {
  flake.nixosModules.scripts = { config, lib, pkgs, ... }:
  let
    cfg = config.device.features.scripts;

    scriptFiles = lib.filterAttrs
      (name: type: type == "regular" && name != "scripts.nix" && !(lib.hasSuffix ".nix" name))
      (builtins.readDir ./.);

    extraDeps = {
      clipcompress = [ pkgs.ffmpeg ];
    };

    mkScript = name: _:
      pkgs.writeShellApplication {
        inherit name;
        text = builtins.readFile (./. + "/${name}");
        runtimeInputs = extraDeps.${name} or [ ];
      };
  in {
    options.device.features.scripts.enable = lib.mkEnableOption "Personal shell scripts";

    config = lib.mkIf cfg.enable {
      environment.systemPackages = lib.mapAttrsToList mkScript scriptFiles;
    };
  };
}

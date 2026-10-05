{ self, ... }: {
  flake.nixosModules.ardour-plugins = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.software.ardour.plugins;
    user = config.internal.username;

    # Vital's standalone GL context renders black under XWayland with hardware
    # GL; force software rendering for the standalone binary only.
    vital-softgl = pkgs.symlinkJoin {
      name = "vital-softgl";
      paths = [ pkgs.vital ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/Vital --set-default LIBGL_ALWAYS_SOFTWARE 1
      '';
    };
  in {
    options.device.features.software.ardour.plugins = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable the standard suite of audio plugins.";
      };
      
      packages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = with pkgs; [
          vital-softgl
          calf
          lsp-plugins
          zam-plugins mda_lv2
          swh_lv2
          infamousPlugins
          dragonfly-reverb
          x42-plugins
        ];
      };
    };

    config = lib.mkIf cfg.enable {
      home-manager.users.${user}.home.packages = cfg.packages;
    };
  };
}

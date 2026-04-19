{ self, ... }: {
  flake.nixosModules.mpv = { config, lib, pkgs, ... }:
  let
    cfg = config.device.features.tools.mpv;
    user = config.internal.username;
  in {
    options.device.features.tools.mpv = {
      enable = lib.mkEnableOption "MPV media engine";
    };

    config = lib.mkIf cfg.enable {
      home-manager.users.${user} = {
        programs.mpv = {
          enable = true;
          config = {
            profile = "gpu-hq";
            vo = "gpu-next";
            gpu-api = "vulkan";
            hwdec = "nvdec";
            save-position-on-quit = true;
          };
          scripts = [ pkgs.mpvScripts.mpris ];
        };
      };
    };
  };
}

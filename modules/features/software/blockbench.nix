{ self, ... }: {
  flake.nixosModules.blockbench = { config, lib, pkgs, ... }:
  let
    cfg = config.device.features.software.blockbench;
    blockbench-4_12_6 = pkgs.appimageTools.wrapType2 {
      pname = "blockbench";
      version = "4.12.6";
      src = pkgs.fetchurl {
        url = "https://github.com/JannisX11/blockbench/releases/download/v4.12.6/Blockbench_4.12.6.AppImage";
        sha256 = "0rlmswz85iirmvqiilzhvnmssklph596bajam9ilxcg2gqfl8p42";
      };
    };
  in {
    options.device.features.software.blockbench.enable = lib.mkEnableOption "Blockbench";
    config = lib.mkIf cfg.enable {
      environment.systemPackages = [ blockbench-4_12_6 ];
    };
  };
}

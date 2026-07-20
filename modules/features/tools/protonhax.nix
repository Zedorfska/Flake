{ self, ... }: {
  flake.nixosModules.protonhax = { config, lib, pkgs, ... }:
  let
    cfg = config.device.features.tools.protonhax;

    protonhax = pkgs.stdenvNoCC.mkDerivation rec {
      pname = "protonhax";
      version = "main";
      src = pkgs.fetchFromGitHub {
        owner = "jcnils";
        repo = "protonhax";
        rev = version;
        hash = "sha256-P6DVRz8YUF4JY2tiEVZx16FtK4i/rirRdKKZBslbJxU=";
      };

      dontBuild = true;
      dontConfigure = true;
      installPhase = ''
        runHook preInstall
        install -Dm755 protonhax $out/bin/protonhax
        runHook postInstall
      '';

      meta = with lib; {
        description = "Run programs inside your game's proton environment";
        homepage = "https://github.com/jcnils/protonhax";
        license = licenses.bsd3;
        platforms = platforms.linux;
        mainProgram = "protonhax";
      };
    };
  in {
    options.device.features.tools.protonhax.enable = lib.mkEnableOption "protonhax";
    config = lib.mkIf cfg.enable {
      environment.systemPackages = [ protonhax ];
    };
  };
}

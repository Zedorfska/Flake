{ self, ... }: {
  flake.nixosModules.swc-launch = { pkgs, lib, config, ... }: 
  let
    wld-pkg = pkgs.stdenv.mkDerivation {
      pname = "wld";
      version = "git";
      src = pkgs.fetchFromGitHub {
        owner = "michaelforney";
        repo = "wld";
        rev = "master";
        hash = "sha256-Z46XLAzRwjmW5yQTBZZ+AYFziK6cjoE9sJ+huuobycY="; 
      };
      nativeBuildInputs = [ pkgs.pkg-config pkgs.wayland-scanner ];
      buildInputs = [ 
        pkgs.pixman pkgs.libdrm pkgs.wayland 
        pkgs.wayland-protocols pkgs.fontconfig pkgs.freetype 
      ];
      installFlags = [ "DESTDIR=$(out)" "PREFIX=" ];
    };

    swc-launcher-pkg = pkgs.stdenv.mkDerivation {
      pname = "swc-launch";
      version = "1.0";
      src = pkgs.fetchFromGitHub {
        owner = "michaelforney";
        repo = "swc";
        rev = "master"; 
        hash = "sha256-/yj6J+TR4dJSi1lIu8YF4dg2gQ1oRkvYRgOmTfEoVio=";
      };

      nativeBuildInputs = [ pkgs.pkg-config pkgs.wayland-scanner ];
      buildInputs = [ 
        pkgs.libdrm pkgs.libinput pkgs.systemd pkgs.pixman 
        pkgs.wayland pkgs.wayland-protocols pkgs.libxkbcommon
        pkgs.fontconfig pkgs.freetype pkgs.libxcb pkgs.xcbutilwm
        wld-pkg 
      ];
      
      PKG_CONFIG_PATH = "${wld-pkg}/lib/pkgconfig";

      # Changed: Use default make and manually install the specific launch binary
      # Most swc versions build swc-launch by default or as part of 'all'
      installPhase = ''
        mkdir -p $out/bin
        # We check for the binary after the build; Michael Forney's makefile
        # usually produces 'swc-launch' in the root or a subfolder.
        cp swc-launch $out/bin/ || cp launch/swc-launch $out/bin/
      '';
    };
  in {
    options.device.features.services.swc-launch.enable = lib.mkEnableOption "swc-launch setuid wrapper";

    config = lib.mkIf config.device.features.services.swc-launch.enable {
      security.wrappers.swc-launch = {
        owner = "root";
        group = "root";
        source = "${swc-launcher-pkg}/bin/swc-launch";
        setuid = true;
      };
    };
  };
}

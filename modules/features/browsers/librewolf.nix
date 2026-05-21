{ self, ... }: {
  flake.nixosModules.librewolf = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.browsers.librewolf;
    user = config.internal.username;
    nasinNanpaFont = "${pkgs.nasin-nanpa}/share/fonts/opentype/nasin-nanpa.otf";
  in {
    options.device.features.browsers.librewolf.enable = lib.mkEnableOption "LibreWolf Browser";

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [ pkgs.librewolf ];

      home-manager.users.${user} = {
        programs.librewolf = {
          enable = true;
          
          settings = {
            "browser.startup.homepage" = "about:blank";
            "privacy.trackingprotection.enabled" = true;
            
            # Required for dark mode/proper CSS etc.
            "privacy.resistFingerprinting" = false;
            
            # Reload tabs automatically
            "browser.startup.page" = 3;

            # sitelen pona
            "security.fileuri.strict_origin_policy" = false;
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          };

          policies = {
            ExtensionSettings = {
              "uBlock0@raymondhill.net" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
                installation_mode = "force_installed";
              };
              "sponsorBlocker@ajay.app" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
                installation_mode = "force_installed";
              };

            };

            DisablePocket = true;
            DisableFirefoxScreenshots = true;

            Cookies = {
              Default = true;
              AcceptThirdParty = "never";
              Allow = [
                "https://github.com"
                "https://youtube.com"
              ];
            };
          };

          profiles.default = {
            isDefault = true;
            userContent = ''
  @font-face {
    font-family: "nasin-nanpa";
    src: url("file://${nasinNanpaFont}");
    unicode-range: U+F1900-U+F19FF;
  }

  @-moz-document url-prefix("") {
    * {
      font-family: inherit, "nasin-nanpa";
    }
  }
'';
          };

        };
      };
    };
  };
}

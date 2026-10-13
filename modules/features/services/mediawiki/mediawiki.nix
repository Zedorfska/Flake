{ self, ... }: {
  flake.nixosModules.mediawiki = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.services.mediawiki;
    assets = ./assets;
    url = "https://wiki.beton.gay";
    port = 8080;

    mwBranch = "REL" + builtins.replaceStrings [ "." ] [ "_" ]
      (lib.versions.majorMinor config.services.mediawiki.package.version);

    translate = pkgs.fetchFromGitHub {
      owner = "wikimedia";
      repo = "mediawiki-extensions-Translate";
      rev = mwBranch;
      hash = "sha256-A3Pfk/a/bgyVeefsEPN8wR+0nDJa3s6T/jhTp7dWA4M=";
    };

    universalLanguageSelector = pkgs.fetchFromGitHub {
      owner = "wikimedia";
      repo = "mediawiki-extensions-UniversalLanguageSelector";
      rev = mwBranch;
      hash = "sha256-MGNCiv2QkCOjx9EJ2OCWSAwxxzQLr7bFfKMEB8mMWI4=";
    };
  in {
    options.device.features.services.mediawiki.enable = lib.mkEnableOption "Mediawiki";

    config = lib.mkIf cfg.enable {
      services.caddy = {
        enable = true; #TODO: MOVE CADDY TO SEPERATE MODULE
        virtualHosts."wiki.beton.gay".extraConfig = ''
          reverse_proxy 127.0.0.1:${toString port}
        '';
      };

      services.mediawiki = {
        enable = true;
        inherit url;

        name = "Beton Wiki";

        extensions = {
          Translate = translate;
          UniversalLanguageSelector = universalLanguageSelector;
        };

        passwordSender = "Zedorfska";
        passwordFile = "/var/lib/mediawiki/admin.pw";

        httpd.virtualHost = {
          listen = [
            {
              ip = "*";
              inherit port;
              ssl = false;
            }
          ];
          extraConfig = ''
            Alias /site-assets ${assets}
            <Directory ${assets}>
              Require all granted
            </Directory>
          '';
        };

        extraConfig = ''
          # BETON
          $wgLogos = [
            '1x' => "${url}/site-assets/logo.png?v=4",
            'wordmark' => [
              'src' => "${url}/site-assets/logo.png?v=4",
              'width' => 640,
              'height' => 188,
            ],
          ];
          $wgFavicon = "${url}/site-assets/favicon.ico";

          # RESTRICT
          $wgGroupPermissions['*']['createaccount'] = false;
          $wgGroupPermissions['sysop']['createaccount'] = true;

          $wgGroupPermissions['*']['edit'] = false;
          $wgGroupPermissions['*']['createpage'] = false;
          $wgGroupPermissions['*']['createtalk'] = false;
          $wgGroupPermissions['*']['writeapi'] = false;

          # TRANSLATE PERMISSIONS
          $wgGroupPermissions['user']['translate'] = true;
          $wgGroupPermissions['sysop']['pagetranslation'] = true;
          $wgGroupPermissions['sysop']['translate-manage'] = true;

          # DARKMODE
          $wgDefaultUserOptions['vector-theme'] = 'night';

          # LANGUAGES
          $wgLanguageCode = 'hr';
          $wgDefaultUserOptions['language'] = 'en';
          $wgULSLanguageDetection = false;
          $wgPageTranslationLanguageList = 'sidebar-only';

          # HIDE BUTTONS + LOGO ICON, SIZE WORDMARK
          $wgHooks['BeforePageDisplay'][] = function ( $out, $skin ) {
            $out->addInlineStyle('
              #n-help, #n-help-mediawiki, #n-specialpages, #t-specialpages { display: none; }
              .mw-logo-icon { display: none !important; }

              .mw-logo,
              .mw-logo-container,
              .mw-logo *,
              .mw-logo-wordmark {
                filter: none !important;
                mix-blend-mode: normal !important;
              }

              .mw-logo-wordmark {
                height: clamp(1.75rem, 2.5vw, 2.75rem) !important;
                width: auto !important;
                max-width: none !important;
                flex: none !important;
                object-fit: contain;
                transform: scale(1.5);
                transform-origin: left center;
              }

              .skin-theme-clientpref-day .mw-logo-wordmark {
                content: url("${url}/site-assets/logo-lightmode.png?v=1");
              }

              @media (prefers-color-scheme: light) {
                .skin-theme-clientpref-os .mw-logo-wordmark {
                  content: url("${url}/site-assets/logo-lightmode.png?v=1");
                }
              }
            ');
          };

          # SIDEBAR
          $wgDefaultUserOptions['vector-main-menu-pinned'] = 1;
          $wgVectorDefaultSidebarVisibleForAnonymousUser = true;
        '';
      };
    };
  };
}

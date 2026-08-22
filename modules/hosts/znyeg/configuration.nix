{ self, inputs, ... }: {
  
  flake.nixosModules.ZnyegConfiguration = { pkgs, lib, config, ... }: {
    boot.kernelPackages = pkgs.linuxPackages_latest;

    networking.hostName = "Znyeg";
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    networking.firewall.allowedTCPPorts = [
      443 80 # Webserver
      8100 # Bluemap
      25565 # Minecraft
      47984 47989 48010 # Sunshine
    ];
    networking.firewall.allowedUDPPorts = [
      24454 # SVC
      47998 47999 48000 48002 48010 # Sunshine
    ];

    environment.variables = {
      #$EDITOR is defined in nvf.nix for when nvim is default
      BROWSER = lib.mkIf config.device.features.browsers.firefox.enable "firefox";
    };

    system.stateVersion = "25.11";
    boot.loader.systemd-boot.enable = true;
        
    device.core.localisation.enable = true;
    device.features = {

        drivers.nvidia.enable = false;
        drivers.amd.enable = true;

        services = {
          gpu-screen-recorder.enable = true;
          swww.enable = false;
          kanshi.enable = true;
          pipewire.enable = true;
          mpd = {
            enable = true;
            musicDirectory = "/mnt/hdd/music";
          };
          mpvpaper.enable = false;
          mprisence.enable = true;
          phonto.enable = true;
          hyprpolkitagent.enable = false;
        };

        environments = {
          hyprland.enable = true;
          dwl.enable = true;
          #hevel.enable = false;
        };

        filemanagers = {
          dolphin.enable = true;
        };

        shells = {
          mksh.enable = true;
        };

        terminals = {
          kitty.enable = true;
          foot.enable = true;
        };

        launchers = {
          wofi.enable = true;
          wmenu.enable = true;
        };

        programming = {
          rust.enable = true;
        };

        scripts.enable = true;

        browsers = {
          librewolf.enable = true;
          firefox.enable = true;
        };

        cli = {
          fastfetch.enable = true;
          base.enable = true;
          rmpc.enable = true;
          tty-clock = {
            enable = true;
            center = true;
            twentyFour = true;
          };
          nvf.enable = true;
          yt-dlp.enable = true;
          networkmanager.enable = true;
          gitui.enable = true;
        };

        tools = {
          ffmpeg.enable = true;
	        hyprshot.enable = true;
          portals.enable = true;
          mpv.enable = true;
          qemu.enable = false;
          wshowkeys.enable = true;
          protonhax.enable = true;
        };

        software = {
          aseprite.enable = true;
          ardour =
          {
            enable = true;
            #plugins = true;
            #vstDir = "";
            #vst3Dir = "";
            #lv2Dir = "";
            #ladspaDir = "";
          };
          gimp.enable = true;
          inkscape.enable = true;
          kdenlive.enable = true;
          obsidian.enable = true;
          libreoffice.enable = true;
          blockbench.enable = true;
          godot.enable = true;
          sunshine.enable = true;
        };

        chat = {
          nixcord.enable = true;
        };

        gaming = {
          steam.enable = true;
          prism.enable = true;
          wine.enable = true;
          vintagestory.enable = false;
          bottles.enable = false;
        };

        themes = {
          dark.enable = true;
          #stylix.enable = true;
        };
    };
   
    imports = [
      # Hardware
      self.nixosModules.ZnyegHardware
      self.nixosModules.nvidia
      self.nixosModules.amd
      self.nixosModules.localisation
      
      # Users
      self.nixosModules.primaryUser
      
      # Home Manager
      self.nixosModules.home-manager
      
      # Fonts
      self.nixosModules.fonts
      
      # Unfree
      self.nixosModules.unfree
      
      
      #
      self.nixosModules.theme
      
      
      self.nixosModules.software-bundle
      self.nixosModules.browsers-bundle
      self.nixosModules.chat-bundle
      self.nixosModules.cli-bundle
      self.nixosModules.environments-bundle
      self.nixosModules.gaming-bundle
      self.nixosModules.launchers-bundle
      self.nixosModules.programming-bundle
      self.nixosModules.scripts
      self.nixosModules.services-bundle
      self.nixosModules.shells-bundle
      self.nixosModules.terminals-bundle
      self.nixosModules.tools-bundle
      self.nixosModules.filemanagers-bundle
    ];
  };
}

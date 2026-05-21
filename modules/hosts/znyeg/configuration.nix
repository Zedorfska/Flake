{ self, inputs, ... }: {
  
  flake.nixosModules.ZnyegConfiguration = { pkgs, ... }: {
    
    networking.hostName = "Znyeg";
    
    fileSystems."/mnt/nvme" = {
      device = "/dev/disk/by-uuid/95ee0e26-d3ca-4f07-b5ba-0343bc802a17";
      fsType = "ext4";
    };
    
    system.stateVersion = "25.11";
    boot.loader.systemd-boot.enable = true;
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    
    device.core.localisation.enable = true;
    device.features = {

        drivers.nvidia.enable = true;

        services = {
          gpu-screen-recorder.enable = true;
          swww.enable = false;
          kanshi.enable = true;
          pipewire.enable = true;
          mpvpaper.enable = true;
        };

        environments = {
          hyprland.enable = true;
          #hevel.enable = false;
        };

        filemanagers = {
          dolphin.enable = true;
        };

        terminals = {
          kitty.enable = true;
          foot.enable = true;
        };

        launchers = {
          wofi.enable = true;
        };

        programming = {
          rust.enable = true;
        };

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
        };

        chat = {
          nixcord.enable = true;
        };

        gaming = {
          steam.enable = true;
          prism.enable = true;
        };

        themes = {
          dark.enable = true;
          #stylix.enable = true;
        };
    };
    
    environment.variables = {
      WLR_NO_HARDWARE_CURSORS = "1";
    };
    
    imports = [
      # Hardware
      self.nixosModules.ZnyegHardware
      self.nixosModules.nvidia
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
      self.nixosModules.services-bundle
      self.nixosModules.terminals-bundle
      self.nixosModules.tools-bundle
      self.nixosModules.filemanagers-bundle
    ];
  };
}




{ self, lib, config, ... }: {
  flake.nixosModules.localisation = { lib, config, ... }: {
    
    options.device.core.localisation.enable = lib.mkEnableOption "system localization (Croat layout & Timezone)";

    config = lib.mkIf config.device.core.localisation.enable {
      time.timeZone = "Europe/Zagreb";

      i18n.defaultLocale = "en_US.UTF-8";

      i18n.extraLocaleSettings = {
        LC_TIME = "hr_HR.UTF-8"; 

        LC_MEASUREMENT = "hr_HR.UTF-8";
        LC_MONETARY = "hr_HR.UTF-8";
      };

      console.keyMap = "croat";

      services.xserver.xkb = {
        layout = "hr,rs";
        variant = ","; 
        options = "grp:win_space_toggle";
      };
    };
  };
}

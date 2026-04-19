{ self, ... }: {
  flake.nixosModules.ardour = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.software.ardour;
    pluginCfg = config.device.features.software.ardour.plugins;
    user = config.internal.username;
    
    activePackages = if pluginCfg.enable then pluginCfg.packages else [];
    
    pluginBase = ./plugins; 
  in {
    imports = [ self.nixosModules.ardour-plugins ];
    
    options.device.features.software.ardour = {
      enable = lib.mkEnableOption "Ardour DAW";

      vstDir = lib.mkOption { type = lib.types.str; default = "${pluginBase}/vst"; };
      vst3Dir = lib.mkOption { type = lib.types.str; default = "${pluginBase}/vst3"; };
      lv2Dir = lib.mkOption { type = lib.types.str; default = "${pluginBase}/lv2"; };
      ladspaDir = lib.mkOption { type = lib.types.str; default = "${pluginBase}/ladspa"; };
    };

    config = lib.mkIf cfg.enable {
      security.rtkit.enable = true;
      security.pam.loginLimits = [
        { domain = "@audio"; item = "memlock"; type = "-"; value = "unlimited"; }
        { domain = "@audio"; item = "rtprio";  type = "-"; value = "99"; }
      ];
      users.users.${user}.extraGroups = [ "audio" ];

      home-manager.users.${user} = {
        home.packages = [ pkgs.ardour ];
        
        home.sessionVariables = {
          GDK_BACKEND = "x11";

          # Construct paths using both Nix Store packages and your local dirs
          LV2_PATH    = "${lib.makeSearchPath "lib/lv2" activePackages}:${cfg.lv2Dir}:$LV2_PATH";
          VST_PATH    = "${lib.makeSearchPath "lib/vst" activePackages}:${cfg.vstDir}:$VST_PATH";
          VST3_PATH   = "${lib.makeSearchPath "lib/vst3" activePackages}:${cfg.vst3Dir}:$VST3_PATH";
          LADSPA_PATH = "${lib.makeSearchPath "lib/ladspa" activePackages}:${cfg.ladspaDir}:$LADSPA_PATH";
        };
      };
    };
  };
}

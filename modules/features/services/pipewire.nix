{ self, ... }: {
  flake.nixosModules.pipewire = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.services.pipewire;
  in {
    options.device.features.services.pipewire.enable = lib.mkEnableOption "PipeWire sound server";

    config = lib.mkIf cfg.enable {
      security.rtkit.enable = true;

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true; # Critical for Steam/Gaming
        pulse.enable = true;      # Compatibility for PulseAudio apps (Discord, etc.)
        jack.enable = true;       # Compatibility for Pro Audio apps
        
        # Optional: Enable the WirePlumber session manager explicitly if needed
        # wireplumber.enable = true;
      };
      
      environment.systemPackages = [ pkgs.pulsemixer ];
    };
  };
}

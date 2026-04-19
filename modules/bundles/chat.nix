{ self, ... }: {
  flake.nixosModules.chat-bundle = { config, lib, ... }: 
  let
    cfg = config.device.features.chat.bundles.everything;
  in {
    imports = [
      self.nixosModules.nixcord
    ];
    
    options.device.features.chat.bundles.everything.enable = lib.mkEnableOption "Chatting programs";

    config = lib.mkIf cfg.enable {
      device.features.chat = {
        nixcord.enable = lib.mkDefault true;
      };
    };
  };
}

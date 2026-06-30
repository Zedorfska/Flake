{ self, ... }: {
  flake.nixosModules.chat-bundle = { ... }: {
    imports = [
      self.nixosModules.nixcord
    ];
  };
}

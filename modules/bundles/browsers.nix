{ self, ... }: {
  flake.nixosModules.browsers-bundle = { ... }: {
    imports = [
      self.nixosModules.librewolf
      self.nixosModules.firefox
    ];
  };
}

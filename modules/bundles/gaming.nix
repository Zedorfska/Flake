{ self, ... }: {
  flake.nixosModules.gaming-bundle = { ... }: {
    imports = [
      self.nixosModules.steam
      self.nixosModules.prism
      self.nixosModules.wine
      self.nixosModules.vintagestory
      self.nixosModules.bottles
    ];
  };
}

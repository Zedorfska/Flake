{ self, ... }: {
  flake.nixosModules.programming-bundle = { ... }: {
    imports = [
      self.nixosModules.rust
    ];
  };
}

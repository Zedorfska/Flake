{ self, ... }: {
  flake.nixosModules.shells-bundle = { ... }: {
    imports = [
      self.nixosModules.mksh
    ];
  };
}

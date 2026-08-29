{ self, ... }: {
  flake.nixosModules.shells-bundle = { ... }: {
    imports = [
      self.nixosModules.bash
      self.nixosModules.mksh
    ];
  };
}

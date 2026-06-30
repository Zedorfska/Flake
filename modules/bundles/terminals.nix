{ self, ... }: {
  flake.nixosModules.terminals-bundle = { ... }: {
    imports = [
      self.nixosModules.foot
      self.nixosModules.kitty
    ];
  };
}

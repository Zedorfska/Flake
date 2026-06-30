{ self, ... }: {
  flake.nixosModules.launchers-bundle = { ... }: {
    imports = [
      self.nixosModules.wofi
    ];
  };
}

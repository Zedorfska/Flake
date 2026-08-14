{ self, ... }: {
  flake.nixosModules.launchers-bundle = { ... }: {
    imports = [
      self.nixosModules.wofi
      self.nixosModules.wmenu
    ];
  };
}

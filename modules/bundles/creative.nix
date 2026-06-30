{ self, ... }: {
  flake.nixosModules.creative-bundle = { ... }: {
    imports = [
      self.nixosModules.gimp
      self.nixosModules.inkscape
      self.nixosModules.kdenlive
      self.nixosModules.ardour
    ];
  };
}

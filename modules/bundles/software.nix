{ self, ... }: {
  flake.nixosModules.software-bundle = { ... }: {
    imports = [
      self.nixosModules.aseprite
      self.nixosModules.creative-bundle
      self.nixosModules.obsidian
      self.nixosModules.libreoffice
      self.nixosModules.blockbench
      self.nixosModules.godot
      self.nixosModules.ciscopackettracer
      self.nixosModules.sunshine
    ];
  };
}

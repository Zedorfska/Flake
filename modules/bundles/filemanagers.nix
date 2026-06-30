{ self, ... }: {
  flake.nixosModules.filemanagers-bundle = { ... }: {
    imports = [
      self.nixosModules.dolphin
    ];
  };
}

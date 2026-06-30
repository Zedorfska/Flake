{ self, ... }: {
  flake.nixosModules.environments-bundle = { ... }: {
    imports = [
      self.nixosModules.twm

      self.nixosModules.hevel
      self.nixosModules.hyprland
      self.nixosModules.niri
      self.nixosModules.dwl
    ];
  };
}

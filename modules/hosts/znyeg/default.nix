{ self, inputs, ... }: {
  
  flake.nixosConfigurations.Znyeg = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.ZnyegConfiguration
    ];
  };
}

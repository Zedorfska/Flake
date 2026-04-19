{ self, inputs, ... }: {
  
  flake.nixosModules.home-manager = { lib, ... }: {
    imports = [
      inputs.home-manager.nixosModules.home-manager
    ];

    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;
      backupFileExtension = "backup";
      #force = true; # Evil mode
    };
  };
}

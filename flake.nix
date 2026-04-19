{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    
    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";
    
    #neu-nix.url = "github:ricardomaps/neu-nix"; # Hevel is here, this breaks everything lol
    
    #stylix.url = "github:danth/stylix";
    
    nixcord.url = "github:FlameFlag/nixcord";
  };
  
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; }
      (inputs.import-tree ./modules);
}

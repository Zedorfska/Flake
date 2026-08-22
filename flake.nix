{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    # Pinned because rebuilding is eh
    nixpkgs-aseprite.url = "github:NixOS/nixpkgs/b7c2ada94fe99c15b0dbcf4d11fd7850b957a436";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    
    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";
    
    #neu-nix.url = "github:ricardomaps/neu-nix"; # Hevel is here, this breaks everything lol
    
    #stylix.url = "github:danth/stylix";
    
    nixcord.url = "github:4evy/nixcord";
    nvf.url = "github:notashelf/nvf";

    phonto.url = "github:museslabs/phonto";

    millenium.url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
  };
  
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; }
      (inputs.import-tree ./modules);
}

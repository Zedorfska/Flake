{ self, ... }: { # TODO: Split into different packages, enabled by those which need that font
  flake.nixosModules.fonts = { pkgs, ... }: {
    fonts.packages = with pkgs; [
      geist-font

      nerd-fonts.symbols-only 
    ];
  };
}

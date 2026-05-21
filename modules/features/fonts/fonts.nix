{ self, ... }: {
  flake.nixosModules.fonts = { pkgs, ... }: {
    fonts.packages = with pkgs; [
      geist-font
      nerd-fonts.symbols-only
      nasin-nanpa
    ];

    fonts.fontconfig.localConf = ''
      <?xml version="1.0"?>
      <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
      <fontconfig>
        <alias>
          <family>sans-serif</family>
          <accept><family>nasin-nanpa</family></accept>
        </alias>
        <alias>
          <family>serif</family>
          <accept><family>nasin-nanpa</family></accept>
        </alias>
        <alias>
          <family>monospace</family>
          <accept><family>nasin-nanpa</family></accept>
        </alias>
      </fontconfig>
    '';
  };
}

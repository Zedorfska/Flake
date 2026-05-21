{ self, ... }: {
  flake.nixosModules.rust = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.programming.rust;
    user = config.internal.username;
  in
  {
    options.device.features.programming.rust.enable = lib.mkEnableOption "Blazing fast and memory safe";

    config = lib.mkIf cfg.enable {
      home-manager.users.${user} = {
        home.packages = with pkgs; [
          rustc
          cargo
          
          # Essential quality-of-life tools
          rust-analyzer # LSP for nvf/neovim
          rustfmt       # Formatter
          clippy        # Linter
          
          gcc
        ];

        home.sessionVariables = {
          CARGO_HOME = "$HOME/.local/share/cargo";
          PATH = "$PATH:$HOME/.local/share/cargo/bin";
        };
      };
    };
  };
}

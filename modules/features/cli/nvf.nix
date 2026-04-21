{ self, inputs, ... }: {
  flake.nixosModules.nvf = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.cli.nvf;
  in {
    imports = [ inputs.nvf.nixosModules.default ];

    options.device.features.cli.nvf.enable = lib.mkEnableOption "NVF (Neovim Flake)";

    config = lib.mkIf cfg.enable {
      programs.nvf = {
        enable = true;
        settings = {
          vim = {
            viAlias = true;
            vimAlias = true;
            preventJunkFiles = true;
            clipboard.registers.copy-paste.enable = true;

            lsp.enable = true;
            telescope.enable = true;
            treesitter.enable = true;
            autocomplete.nvim-cmp.enable = true;
            statusline.lualine.enable = true;
            
            theme = {
              enable = true;
              name = "tokyonight";
              style = "night";
            };

            visuals = {
              nvimWebDevicons.enable = true;
              cursorline.enable = true;
              indent-blankline.enable = true;
            };
            
            globals.mapleader = " ";
          };
        };
      };
    };
  };
}

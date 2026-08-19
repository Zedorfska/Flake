{ self, inputs, ... }: {
  flake.nixosModules.nvf = { config, lib, pkgs, ... }: 
  let
    cfg = config.device.features.cli.nvf;

    # TODO: Figure ts out
    bash    = true;
    rust    = config.device.features.programming.rust.enable;
    lua     = true; #config.device.features.programming.lua.enable;
    #python  = config.device.features.programming.python.enable;
    #csharp  = config.device.features.programming.csharp.enable;
    nix     = true;

  in {
    imports = [ inputs.nvf.nixosModules.default ];

    options.device.features.cli.nvf.enable = lib.mkEnableOption "NVF (Neovim Flake)";

    config = lib.mkIf cfg.enable {
      programs.nvf = {
        enable = true;
        defaultEditor = true;
        settings = {
          vim = {
            ###
            globals.mapleader = " ";
            maps.normal = {
              "<leader>e" = {
              action = "<cmd>lua vim.diagnostic.open_float()<CR>";
              desc = "Open diagnostic float";
              };
            };
            autocmds = [
              {
                event = [ "FileType" ];
                pattern = [ "nix" ];
                command = "setlocal tabstop=2 shiftwidth=2 expandtab";
              }
              {
                event = [ "FileType" ];
                pattern = [ "rust" ];
                command = "setlocal tabstop=4 shiftwidth=4 expandtab";
              }
              {
                event = [ "FileType" ];
                pattern = [ "sh" "bash" ];
                command = "setlocal tabstop=4 shiftwidth=4 expandtab";
              }
              {
                event = [ "FileType" ];
                pattern = [ "lua" ];
                command = "setlocal tabstop=2 shiftwidth=2 expandtab";
              }
            ];
            ###

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
              nvim-web-devicons.enable = true;
              nvim-cursorline.enable = true;
              indent-blankline.enable = true;
            };
            
            languages = {
              bash.enable = bash;
              nix.enable  = nix;
              rust.enable = rust;
              lua.enable  = lua;
              #python.enable = python;
              #csharp.enable = csharp;
            };
          };
        };
      };
    };
  };
}

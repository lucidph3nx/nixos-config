{pkgs, ...}:
{
  home.packages = with pkgs; [
    stylua
    alejandra
    black
  ];
  programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.conform-nvim;
      type = "lua";
      config = 
        /*
        lua
        */
        ''
        require('colorizer').setup {
          formatters_by_ft = {
            lua = { "stylua" },
            python = { "black" },
            nix = { "alejandra" },
          }
        }
        -- Keybindings
        vim.keymap.set(
          'n', '<leader>f',
          require("conform").format({ async = true, lsp_fallback = true }),
          { desc = "Format the current buffer" })
        '';
    }
  ];
}

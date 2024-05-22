{pkgs, ...}: {
  home.packages = with pkgs; [
    stylua
    alejandra
    black
    jq
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
          require('conform').setup {
            formatters_by_ft = {
              lua = { "stylua" },
              python = { "black" },
              nix = { "alejandra" },
              json = { "jq" },
            }
          }
          -- Keybindings
          vim.keymap.set(
            'n', '<leader>f',
            function()
              require("conform").format({ async = true, lsp_fallback = true })
            end,
            { desc = "Format the current buffer" })
        '';
    }
  ];
}

{pkgs, ...}: {
  home-manager.users.ben.home.packages = with pkgs; [
    stylua
    alejandra
    black
    jq
  ];
  home-manager.users.ben.programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.conform-nvim;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require("conform").setup({
          	formatters_by_ft = {
          		lua = { "stylua" },
          		python = { "black" },
          		nix = { "alejandra", "injected" },
          		json = { "jq" },
          	},
          })
          -- Keybindings
          vim.keymap.set("n", "<leader>f", function()
          	require("conform").format({ async = true, lsp_fallback = true })
          end, { desc = "Format the current buffer" })
        '';
    }
  ];
}

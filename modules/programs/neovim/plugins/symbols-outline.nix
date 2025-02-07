{pkgs, ...}: {
  home-manager.users.ben.programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.symbols-outline-nvim;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require("symbols-outline").setup({
          	highlight_hovered_item = true,
          	show_guides = true,
          	auto_preview = false,
          	position = "right",
          	keymaps = {
          		close = { "<Esc>", "q" },
          		goto_location = "<Cr>",
          		focus_location = "o",
          		hover_symbol = "<C-space>",
          		toggle_preview = "K",
          		rename_symbol = "r",
          		code_actions = "a",
          		fold = "h",
          		unfold = "l",
          		fold_all = "W",
          		unfold_all = "E",
          		fold_reset = "R",
          	},
          	lsp_blacklist = {},
          })
          vim.keymap.set("n", "<leader>to", vim.cmd.SymbolsOutline, { desc = "[T]oggle [O]utline" })
        '';
    }
  ];
}

{pkgs, ...}: {
  home-manager.users.ben.programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.zen-mode-nvim;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require("zen-mode").setup({
            window = {
              backdrop = 1,
              width = 1,
              options = {
                number = false,
              },
            },
          	plugins = {
          		tmux = { enabled = true },
          		kitty = {
          			enabled = true,
          			font = "+2",
          		},
          	},
          })
          vim.keymap.set("n", "<leader>z", vim.cmd.ZenMode, { desc = "[Z]enMode" })
        '';
    }
  ];
}

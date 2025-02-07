{pkgs, ...}: {
  home-manager.users.ben.programs.neovim.plugins = [
    pkgs.vimPlugins.nvim-web-devicons
    {
      plugin = pkgs.vimPlugins.oil-nvim;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require("oil").setup({
          	view_options = {
          		show_hidden = true,
          	},
          	-- don't want to disable netrw,
          	-- that causes a bunch of other functionality to break
          	default_file_explorer = false,
          })
          vim.keymap.set("n", "-", vim.cmd.Oil, { desc = "open parent directory" })
        '';
    }
  ];
}

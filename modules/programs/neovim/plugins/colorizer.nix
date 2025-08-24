{ pkgs, ... }:
{
  home-manager.users.ben.programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.nvim-colorizer-lua;
      type = "lua";
      config =
        # lua
        ''
          require("colorizer").setup({
          	filetypes = { "*" },
          	user_default_options = {
          		-- don't colorize names
          		names = false,
          	},
          })
        '';
    }
  ];
}

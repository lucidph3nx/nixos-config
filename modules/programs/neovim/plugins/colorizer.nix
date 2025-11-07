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
            filetypes = { "css", "html", "scss", "nix" },
          	user_default_options = {
          		-- don't colorize names
          		names = false,
          	},
          })
        '';
    }
  ];
}

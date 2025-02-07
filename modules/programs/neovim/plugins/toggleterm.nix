{
  pkgs,
  ...
}: {
  home-manager.users.ben.programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.toggleterm-nvim;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require("toggleterm").setup({
          	open_mapping = [[<C-Space>]],
          	size = 15,
          	shell = "zsh",
          	hide_numbers = true,
          	close_on_exit = true,
          	direction = "float",
          	float_opts = {
          		border = "single",
          		width = 150,
          		height = 30,
          		winblend = 3,
          	},
          })
        '';
    }
  ];
}

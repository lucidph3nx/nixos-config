{
  pkgs,
  lib,
  config,
  ...
}: let
  theme = config.theme;
in {
  home-manager.users.ben.programs.neovim.plugins = lib.mkIf (config.theme.name == "onedark") [
    {
      plugin = pkgs.vimPlugins.onedark-nvim;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require("onedark").setup({
          	highlights = {
          		ObsidianTodo = {
          			fg = "${theme.purple}",
          			bg = "none",
          			fmt = "bold",
          		},
          		ObsidianDone = {
          			fg = "${theme.green}",
          			bg = "none",
          			fmt = "bold",
          		},
          		ObsidianRightArrow = {
          			fg = "${theme.purple}",
          			bg = "none",
          			fmt = "bold",
          		},
          		ObsidianTilde = {
          			fg = "${theme.orange}",
          			bg = "none",
          			fmt = "bold",
          		},
          		ObsidianRefText = {
          			fg = "${theme.blue}",
          			bg = "none",
          		},
          		ObsidianExtLinkIcon = {
          			fg = "${theme.blue}",
          			bg = "none",
          		},
          		ObsidianTag = {
          			fg = "${theme.blue}",
          			bg = "none",
          			fmt = "italic",
          		},
          	},
          })
          vim.cmd("colorscheme onedark")
        '';
    }
  ];
}

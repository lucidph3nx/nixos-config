{
  pkgs,
  lib,
  config,
  ...
}: let
  onedark = pkgs.vimUtils.buildVimPlugin {
    name = "onedark";
    src = pkgs.fetchFromGitHub {
      owner = "navarasu";
      repo = "onedark.nvim";
      rev = "67a74c275d1116d575ab25485d1bfa6b2a9c38a6";
      hash = "sha256-NLHq9SUUo81m50NPQe8852uZbo4Mo4No10N3ptX43t0=";
    };
  };
  theme = config.theme;
in {
  programs.neovim.plugins = lib.mkIf (config.theme.name == "onedark") [
    {
      plugin = onedark;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require('onedark').setup {
            highlights = {
              ObsidianTodo = {
                fg = '${theme.purple}',
                bg = 'none',
                fmt = "bold",
              },
              ObsidianDone = {
                fg = '${theme.green}',
                bg = 'none',
                fmt = "bold",
              },
              ObsidianRightArrow = {
                fg = '${theme.purple}',
                bg = 'none',
                fmt = "bold",
              },
              ObsidianTilde = {
                fg = '${theme.orange}',
                bg = 'none',
                fmt = "bold",
              },
              ObsidianRefText = {
                fg = '${theme.blue}',
                bg = 'none',
                fmt = "underline",
              },
              ObsidianExtLinkIcon = {
                fg = '${theme.blue}',
                bg = 'none',
              },
              ObsidianTag = {
                fg = '${theme.blue}',
                bg = 'none',
                fmt = "italic",
              },

            }
          }
          vim.cmd('colorscheme onedark')
        '';
    }
  ];
}

{
  pkgs,
  lib,
  config,
  ...
}: let
  github-nvim-theme = pkgs.vimUtils.buildVimPlugin {
    name = "github-nvim-theme";
    src = pkgs.fetchFromGitHub {
      owner = "projekt0n";
      repo = "github-nvim-theme";
      rev = "0e4636f556880d13c00d8a8f686fae8df7c9845f";
      hash = "sha256-EreIuni6/XR0428rO4Lbi2usIreOyPWKm7kJJA2Nwqo=";
    };
  };
  theme = config.theme;
in {
  programs.neovim.plugins = lib.mkIf (config.theme.name == "github-light") [
    {
      plugin = github-nvim-theme;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require('github-theme').setup({
            groups = {
              all = {
                ObsidianTodo = {
                  fg = '${theme.blue}',
                  bg = 'none',
                  bold = true
                },
                ObsidianDone = {
                  fg = '${theme.green}',
                  bg = 'none',
                  bold = true
                },
                ObsidianRightArrow = {
                  fg = '${theme.blue}',
                  bg = 'none',
                  bold = true
                },
                ObsidianTilde = {
                  fg = '${theme.orange}',
                  bg = 'none',
                  bold = true
                },
                ObsidianRefText = {
                  fg = '${theme.blue}',
                  bg = 'none',
                  bold = true
                },
                ObsidianExtLinkIcon = {
                  fg = '${theme.blue}',
                  bg = 'none',
                },
                ObsidianTag = {
                  fg = '${theme.blue}',
                  bg = 'none',
                  italic = true
                }
              }
            }
          })
          vim.cmd('colorscheme github_light')
        '';
    }
  ];
}

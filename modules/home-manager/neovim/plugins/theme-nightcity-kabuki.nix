{
  pkgs,
  lib,
  config,
  ...
}: let
  nightcity-theme = pkgs.vimUtils.buildVimPlugin {
    name = "nightcity-theme";
    src = pkgs.fetchFromGitHub {
      owner = "cryptomilk";
      repo = "nightcity.nvim";
      rev = "c38ec1f32f6224da7b9eaf7bb27a8133bcc4c016";
      hash = "sha256-/ATSVsUaiy6yMREVyxFRJZxuWFbcCKxwZiy3EXsssoI=";
    };
  };
  theme = config.theme;
in {
  programs.neovim.plugins = lib.mkIf (config.theme.name == "nightcity-kabuki") [
    {
      plugin = nightcity-theme;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require('nightcity').setup({
            style = 'kabuki',
            on_highlights = function(groups, c)
                -- no bg for String
                groups.String = { fg = c.text }
            end

          --   groups = {
          --     all = {
          --       ObsidianTodo = {
          --         fg = '${theme.blue}',
          --         bg = 'none',
          --         style = 'bold'
          --       },
          --       ObsidianDone = {
          --         fg = '${theme.green}',
          --         bg = 'none',
          --         style = 'bold'
          --       },
          --       ObsidianRightArrow = {
          --         fg = '${theme.blue}',
          --         bg = 'none',
          --         style = 'bold'
          --       },
          --       ObsidianTilde = {
          --         fg = '${theme.orange}',
          --         bg = 'none',
          --         style = 'bold'
          --       },
          --       ObsidianRefText = {
          --         fg = '${theme.blue}',
          --         bg = 'none',
          --         style = 'NONE' -- no underline for obsidian links
          --       },
          --       ObsidianExtLinkIcon = {
          --         fg = '${theme.blue}',
          --         bg = 'none',
          --       },
          --       ObsidianTag = {
          --         fg = '${theme.blue}',
          --         bg = 'none',
          --         style = 'italic'
          --       },
          --       ['@markup.heading.1.markdown'] = {
          --         fg = '${theme.blue}',
          --         bg = 'none',
          --         style = 'bold'
          --       },
          --       ['@markup.heading.2.markdown'] = {
          --         fg = '${theme.green}',
          --         bg = 'none',
          --         style = 'bold'
          --       },
          --       ['@markup.heading.3.markdown'] = {
          --         fg = '${theme.purple}',
          --         bg = 'none',
          --         style = 'bold'
          --       },
          --     }
          --   },
          })
          vim.cmd('colorscheme nightcity')
        '';
    }
  ];
}

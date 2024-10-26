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
          require('github-theme').setup()
          vim.cmd('colorscheme github_light')
        '';
    }
  ];
}

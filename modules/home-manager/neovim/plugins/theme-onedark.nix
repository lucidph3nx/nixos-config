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
          require('onedark').load()
          vim.cmd('colorscheme onedark')
        '';
    }
  ];
}

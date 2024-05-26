{pkgs, ...}: let
  everforest-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "everforest-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "neanias";
      repo = "everforest-nvim";
      rev = "ed4ba26c911696d69cfda26014ec740861d324e1";
      hash = "sha256-kVn6rUc26PtoqzKW/MNuks85sTLYx1lEE/l+7W0bDfg=";
    };
  };
in {
  programs.neovim.plugins = [
    {
      plugin = everforest-nvim;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require('everforest').setup {
            on_highlights = function(hl, palette)
              -- markdown links are underlined
              hl.TSTextReference = {
                fg = palette.aqua,
                bg = palette.none,
                underline = true,
              }
            end
          }
          require("everforest").load()
        '';
    }
  ];
}

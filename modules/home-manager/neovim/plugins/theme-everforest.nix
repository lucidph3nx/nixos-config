{pkgs, lib, ...}:

rec {
  nixpkgs = {
    overlays = [
      (self: super:
        let
          everforest-nvim = super.vimUtils.buildVimPlugin {
            name = "everforest-nvim";
            src = pkgs.fetchFromGitHub {
              owner = "neanias";
              repo = "everforest-nvim";
              rev = "5e0e32a569fb464911342f0d421721cc1c94cf25";
              sha256 = "";
            };
          };
        in {
          vimPlugins =
            super.vimPlugins // { inherit everforest-nvim; };
          }
      )
    ];
  };
  programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.everforest-nvim;
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
        '';
    }
  ];
}

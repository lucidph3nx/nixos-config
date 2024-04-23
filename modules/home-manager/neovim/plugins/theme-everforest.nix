{pkgs, ...}:

let
  everforest-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "everforest-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "neanias";
      repo = "everforest-nvim";
      rev = "5e0e32a569fb464911342f0d421721cc1c94cf25";
      hash = "sha256-qKyPqkcf420eMbgGNXmMgF3i9GZ71NpoqeK3+Gz0fzc=";
    };
  };
in 
{
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

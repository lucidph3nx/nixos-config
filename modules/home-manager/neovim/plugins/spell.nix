{pkgs, ...}:

# need this plugin to download spell files due to bug
# in neovim where spellfile download is depended on netrw
# I use oil.nvim, and so need this plugin
# https://github.com/neovim/neovim/issues/7189

let
  spellfile-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "spellfile.nvim";
    src = pkgs.fetchFromGitHub {
      owner = "cuducos";
      repo = "spellfile.nvim";
      rev = "93349f7961b748d71f192eff7a28c04f6ef64784";
      hash = "";
    };
  };
in 
{
  programs.neovim.plugins = [
    {
      plugin = spellfile-nvim;
      type = "lua";
      config = 
        /*
        lua
        */
        ''
        require('spellfile-nvim').setup {}
        '';
    }
  ];
}

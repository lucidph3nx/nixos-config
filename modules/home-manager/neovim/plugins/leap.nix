{pkgs, ...}:
{
  programs.neovim.plugins = [
    # I used to have a lot of config for these, it wasnt clear what it did...
    # lets see if I miss it
    pkgs.vimPlugins.leap-nvim
    pkgs.vimPlugins.flit-nvim
    pkgs.vimPlugins.vim-repeat
  ];
}

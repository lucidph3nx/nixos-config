{pkgs, ...}: {
  programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.indent-blankline-nvim;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require('ibl').setup {}
        '';
    }
  ];
}

{pkgs, ...}: {
  programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.leap-nvim;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require("leap").create_default_mappings()
        '';
    }
    {
      plugin = pkgs.pkgs.vimPlugins.flit-nvim;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require("flit").setup()
        '';
    }
    pkgs.vimPlugins.vim-repeat
  ];
}

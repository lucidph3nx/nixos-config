{pkgs, ...}: {
  home-manager.users.ben.programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.comment-nvim;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require("Comment").setup({})
        '';
    }
  ];
}

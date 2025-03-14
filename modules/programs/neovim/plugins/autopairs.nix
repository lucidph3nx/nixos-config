{pkgs, ...}: {
  home-manager.users.ben.programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.nvim-autopairs;
      type = "lua";
      config =
        /*
        lua
        */
        ''
          require("nvim-autopairs").setup()
          -- don't close quotes
          require("nvim-autopairs").remove_rule('"')
        '';
    }
  ];
}

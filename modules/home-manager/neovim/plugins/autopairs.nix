{pkgs, ...}:
{
  programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.nvim-autopairs;
      type = "lua";
      config = 
        /*
        lua
        */
        ''
        require('nvim-autopairs').setup()
        -- ${pkgs.vimPlugins.nvim-autopairs}}
        -- don't close quotes
        require('nvim-autopairs').remove_rule('"')
        '';
    }
  ];
}

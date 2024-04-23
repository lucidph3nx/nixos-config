{pkgs, ...}:
{
  programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.undotree;
      type = "lua";
      config = 
        /*
        lua
        */
        ''
        require('undotree').setup {}
        vim.keymap.set('n', '<leader>u',
          vim.cmd.UndotreeToggle, { desc = '[U]ndo Tree' })
        '';
    }
  ];
}

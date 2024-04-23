{pkgs, ...}:
{
  programs.neovim.plugins = [
    pkgs.vimPlugins.nvim-web-devicons
    {
      plugin = pkgs.vimPlugins.oil-nvim;
      type = "lua";
      config = 
        /*
        lua
        */
        ''
        require('oil').setup {
          view_options = {
            show_hidden = true,
          },
        }
        vim.keymap.set('n', '-',
          vim.cmd.Oil, { desc = 'open parent directory' })
        '';
    }
  ];
}

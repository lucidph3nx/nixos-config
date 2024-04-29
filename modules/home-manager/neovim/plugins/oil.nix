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
          -- due to bug, you might need to set this to false
          -- then once you have the spell files, set it back.
          -- https://github.com/neovim/neovim/issues/7189
          default_file_explorer = false,
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

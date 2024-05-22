{pkgs, lib, ...}:
{
  home.packages = with pkgs; [
    nodejs_20
  ];
  programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.copilot-lua;
      type = "lua";
      config = 
        /*
        lua
        */
        ''
        require('copilot').setup {
          panel = {
            enabled = false, -- disabled due to the keymap affecting insert mode
            auto_refresh = false,
            layout = {
              position = "bottom", -- | top | left | right
              ratio = 0.4
            },
            keymap = {
              open = '<leader>cp',
            },
          },
          suggestion = {
            enabled = true,
            auto_trigger = true,
            debounce = 75,
            keymap = {
              accept = '<C-L>',
              next = '<C-J>',
              prev = '<C-K',
            },
          },
          filetypes = {
            markdown = true,
            yaml = true,
            help = false,
            gitcommit = false,
            gitrebase = false,
            hgcommit = false,
            svn = false,
            cvs = false,
            ["."] = true,
            rust = false, -- while learning rust, no copilot
          },
        }
        '';
    }
  ];
}

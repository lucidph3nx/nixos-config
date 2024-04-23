{pkgs, lib, ...}:
{
  programs.neovim.plugins = lib.mkAfter [
    {
      plugin = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
      type = "lua";
      config = 
        /*
        lua
        */
        ''
        require('nvim-treesitter.configs').setup {
          -- Add languages to be installed here that you want installed for treesitter
          ensure_installed = {
            'bash',
            'c',
            'clojure',
            'cpp',
            'go',
            'html',
            'javascript',
            'lua',
            'luadoc',
            'luap',
            'markdown',
            'markdown_inline',
            'nix',
            'python',
            'query',
            'regex',
            'rust',
            'scala',
            'scss',
            'sql',
            'tsx',
            'typescript',
            'vim',
            'vimdoc',
            'yaml',
          },

          -- Autoinstall languages that are not installed
          auto_install = true,
          highlight = {
            enable = true,
            additional_vim_regex_highlighting = { "markdown" },
          },
          indent = { enable = true },
          incremental_selection = {
            enable = true,
            keymaps = {
              init_selection = '<CR>',
              scope_incremental = '<CR>',
              node_incremental = '<TAB>',
              node_decremental = '<S-TAB>',
            },
          },
          textobjects = {
            select = {
              enable = true,
              lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
              keymaps = {
                -- You can use the capture groups defined in textobjects.scm
                ['aa'] = '@parameter.outer',
                ['ia'] = '@parameter.inner',
                ['af'] = '@function.outer',
                ['if'] = '@function.inner',
                ['ac'] = '@class.outer',
                ['ic'] = '@class.inner',
              },
            },
            move = {
              enable = true,
              set_jumps = true, -- whether to set jumps in the jumplist
              goto_next_start = {
                [']m'] = '@function.outer',
                [']]'] = '@class.outer',
              },
              goto_next_end = {
                [']M'] = '@function.outer',
                [']['] = '@class.outer',
              },
              goto_previous_start = {
                ['[m'] = '@function.outer',
                ['[['] = '@class.outer',
              },
              goto_previous_end = {
                ['[M'] = '@function.outer',
                ['[]'] = '@class.outer',
              },
            },
            swap = {
              enable = true,
              swap_next = {
                ['<leader>a'] = '@parameter.inner',
              },
              swap_previous = {
                ['<leader>A'] = '@parameter.inner',
              },
            },
          },
        }
        '';
    }
  ];
}

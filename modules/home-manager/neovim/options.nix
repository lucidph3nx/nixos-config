{ config, lib, pkgs, inputs, ... }:

{
  # Setting various vim options
  programs.neovim = {
    extraConfig = 
      /*
      vim
      */
      ''
        set nu " make line numbers default
        set cursorline " highlight line of cursor
        set spelllang=en_nz,mi
        " tab definitions
        set tabstop=2
        set shiftwidth=2
        set expandtab
        set smarttab
        set smartindent " indent automatically on newline
        set breakindent " wrapped lines should ignore indent
        set nowrap " wrap disabled by default (keybind to toggle)
        set linebreak
        set undofile " save undo history
        set noswapfile " no swap file
        set ignorecase " case insensitive search
        set smartcase " unless a capital letter is used
        set hlsearch " highlight all when searching (esc to clear)
        set termguicolours
        set signcolumn=yes " keep sign column visible
        set noshowmode " using lualine, so don't need this twice
        " when splitting, open new window below/right
        set splitright
        set splitbelow
        set scrolloff=8 "show 8 lines below cursor when scrolling
        " decrease update time
        set updatetime=250
        set timeoutlen= 1000
        set lazyredraw
        " completion settings
        set completeopt=menuone,noselect
        " disable mouse
        set mouse=""
      '';
    extraLuaConfig = 
      /*
      lua
      */
      ''
      -- vim diagnostic messages - tell me the lsp it came from
      vim.diagnostic.config({
      virtual_text = {
          source = true,
          format = function(diagnostic)
              if diagnostic.user_data and diagnostic.user_data.code then
                  return string.format('%s %s', diagnostic.user_data.code, diagnostic.message)
              else
                  return diagnostic.message
              end
          end,
        },
        signs = true,
        float = {
            header = 'Diagnostics',
            source = true,
            border = 'rounded',
        },
      })
      '';
  };
}

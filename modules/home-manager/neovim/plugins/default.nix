{ config, lib, pkgs, inputs, ... }:

{
  # my old neovim config had a one plugin per file structure
  # any plugins which have additional config, I have given them their own file
  # any plugins where i use the default, are just added below
  imports = [
    ./autopairs.nix
    ./colorizer.nix
    ./comment.nix
    ./conform.nix
    ./copilot.nix
    ./gitsigns.nix
    ./image.nix
    ./leap.nix
    ./lualine.nix
    ./luasnip.nix
    ./nvim-cmp.nix
    ./nvim-lspconfig.nix
    ./nvim-sops.nix
    ./nvim-tree.nix
    ./obsidian.nix
    ./oil.nix
    ./spell.nix
    ./symbols-outline.nix
    ./telescope.nix
    ./theme-everforest.nix
    ./toggleterm.nix
    ./treesitter.nix
    ./undotree.nix
    ./vim-fugitive.nix
    ./vim-markdown.nix
  ];
  programs.neovim.plugins = with pkgs.vimPlugins; [
    indent-blankline-nvim
    markdown-preview-nvim
    quickfix-reflector-vim
  ];
}

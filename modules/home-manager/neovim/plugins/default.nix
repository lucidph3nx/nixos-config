{ config, lib, pkgs, inputs, ... }:

{
  # my old neovim config had a one plugin per file structure
  # any plugins which have additional config, I have given them their own file
  # any plugins where i use the default, are just added below
  imports = [
    ./autopairs.nix
    ./colorizer.nix
    ./conform.nix
    ./copilot.nix
    ./gitsigns.nix
    ./image.nix
    ./leap.nix
    ./lualine.nix
    ./luasnip.nix
    ./nvim-cmp.nix
    ./nvim-lspconfig.nix
    # awaiting merge
    # https://github.com/NixOS/nixpkgs/pull/306145
    ./nvim-sops.nix
    ./nvim-tree.nix
    ./obsidian.nix
    ./oil.nix
    ./symbols-outline.nix
    ./telescope.nix
    # not currently in nix packages :(
    # ./theme-everforest.nix
    ./toggleterm.nix
    ./treesitter.nix
    ./undotree.nix
    ./vim-fugitive.nix
    ./vim-markdown.nix
  ];
  programs.neovim.plugins = with pkgs.vimPlugins; [
    comment-nvim
    indent-blankline-nvim
    markdown-preview-nvim
    quickfix-reflector-vim
  ];
}

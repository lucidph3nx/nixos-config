{ config, lib, pkgs, inputs, ... }:

{
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
    ./symbols-outline.nix
    ./telescope.nix
    ./theme-everforest.nix
    ./toggleterm.nix
    ./treesitter.nix
    ./undotree.nix
    ./vim-fugitive.nix
  ];
}

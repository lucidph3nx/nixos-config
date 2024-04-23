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
    # merged but not yet showing in unstable
    # https://search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=nvim-sops
    # ./nvim-sops.nix
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

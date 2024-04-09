{ config, pkgs, ... }:

{
  imports =
  [
    ../../modules/home-manager/asdf.nix
    ../../modules/home-manager/firefox.nix
    ../../modules/home-manager/git.nix
    ../../modules/home-manager/k9s.nix
    ../../modules/home-manager/kitty.nix
    ../../modules/home-manager/lf.nix
    ../../modules/home-manager/mpd.nix
    ../../modules/home-manager/ncmpcpp.nix
    ../../modules/home-manager/nvim.nix
    ../../modules/home-manager/rofi.nix
    ../../modules/home-manager/scripts.nix
    ../../modules/home-manager/sway.nix
    ../../modules/home-manager/swaync.nix
    ../../modules/home-manager/syncthing.nix
    ../../modules/home-manager/tmux.nix
    ../../modules/home-manager/waybar.nix
    ../../modules/home-manager/zathura.nix
    ../../modules/home-manager/zsh.nix
  ];
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "ben";
  home.homeDirectory = "/home/ben";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };
  
  home.packages = with pkgs; [
    pfetch-rs
    neofetch
    picard
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    KUBECONFIG = "/home/ben/.config/kube/config-home";
    PAGER = "less";
    PF_INFO = "ascii title os kernel pkgs wm shell editor";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

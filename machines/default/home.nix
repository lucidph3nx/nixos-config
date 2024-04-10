{ config, pkgs, nixpkgs-unstable, ... }:

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
  
  home.pointerCursor = {
    gtk.enable = true;
    name = "breeze_cursors";
    # this is the cursor I like, from plasma 6
    package = nixpkgs-unstable.kdePackages.breeze;
    size = 24;
  };
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.gnome-themes-extra;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "breeze_cursors";
    # this is the cursor I like, from plasma 6
      package = nixpkgs-unstable.kdePackages.breeze;
    };
    gtk3 = {
      extraConfig.gtk-application-prefer-dark-theme = true;
    };
  };
  qt = {
    enable = true;
    platformTheme = "gnome";
    style.name = "adwaita-dark";
  };
  
  home.packages = with pkgs; [
    pfetch-rs
    neofetch
    picard
    gimp # temp for troubleshooting
    vimiv-qt
    # cinnamon.nemo
  ];

  home.sessionVariables = {
    KUBECONFIG = "/home/ben/.config/kube/config-home";
    PAGER = "less";
    PF_INFO = "ascii title os kernel pkgs wm shell editor";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

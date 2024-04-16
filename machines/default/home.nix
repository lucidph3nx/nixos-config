{ config, pkgs, nixpkgs-unstable, ... }:

{
  imports =
  [
    ../../modules/home-manager/asdf.nix
    ../../modules/home-manager/git.nix
    ../../modules/home-manager/mpd.nix
    ../../modules/home-manager/ncmpcpp.nix
    ../../modules/home-manager/nvim.nix
    # ../../modules/home-manager/prospect-mail.nix
    ../../modules/home-manager/scripts.nix
    ../../modules/home-manager/syncthing.nix
    # ../../modules/home-manager/teams-for-linux.nix
    ../../modules/home-manager/zsh.nix
  ];
  sysDefaults = {
    terminal = "${pkgs.kitty}/bin/kitty";
  };
  homeManagerModules = {
    # Enable home automation stuff as device should be in the home
    homeAutomation.enable = true;
    ssh.client.enable = true;
    ssh.proxymac = true;
  };
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
    gimp # temp for troubleshooting
    neofetch
    pfetch-rs
    picard
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

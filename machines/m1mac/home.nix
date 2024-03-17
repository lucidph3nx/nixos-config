{ config, pkgs, nixpkgs-unstable, ... }:

{
  imports = 
  [
    ../../modules/home-manager/kitty.nix
    ../../modules/home-manager/tmux.nix
    ../../modules/home-manager/mise.nix
    ../../modules/home-manager/nvim.nix
    ../../modules/home-manager/syncthing.nix
    ../../modules/home-manager/git-sync.nix
    ../../modules/home-manager/git.nix
    # aparently doesnt work
    # ../../modules/home-manager/firefox.nix
  ];
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  home.packages = with pkgs; [
    pfetch-rs
    neofetch
  ];
  home.sessionVariables = {
    EDITOR = "nvim";
    KUBECONFIG = "/Users/ben/.config/kube/config-work";
    PAGER = "less";
    PF_INFO = "ascii title os kernel pkgs wm shell editor";
  };
  home.file = {
    ".config/karabiner/karabiner.json".source = ./files/karabiner.json;
    ".config/yabai/mac-focus-space-SIP.sh".source = ./files/mac-focus-space-SIP.sh;
    ".config/yabai/mac-move-space-SIP.sh".source = ./files/mac-move-space-SIP.sh;
  };
}

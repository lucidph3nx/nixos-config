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
    # aparently doesnt work
    # ../../modules/home-manager/firefox.nix
  ];
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  home.packages = with pkgs; [
    ripgrep
    neofetch
  ];
  home.sessionVariables = {
    PAGER = "less";
    EDITOR = "nvim";
  };
  home.file = {
    ".config/karabiner/karabiner.json".source = ./files/karabiner.json;
    ".config/yabai/mac-focus-space-SIP.sh".source = ./files/mac-focus-space-SIP.sh;
    ".config/yabai/mac-move-space-SIP.sh".source = ./files/mac-move-space-SIP.sh;
  };
  programs.git.enable = true;
}

{ config, pkgs, nixpkgs-unstable, inputs, ... }:

{
  imports = 
  [
    ../../modules/home-manager/git-sync.nix
    ../../modules/home-manager/git.nix
    ../../modules/home-manager/nvim.nix
    ../../modules/home-manager/scripts.nix
    ../../modules/home-manager/syncthing.nix
  ];
  sysDefaults = {
    terminal = "${pkgs.kitty}/bin/kitty";
  };
  homeManagerModules = {
    firefox.enable = false; # doesnt work on nix-darwin currently
    desktopEnvironment.enable = false; # desktop environments are for linux only
    sops = {
      enable = true;
      generalSecrets.enable = true;
      signingKeys.enable = true;
      homeSSHKeys.enable = true;
      workSSH.enable = true;
      kubeconfig.enable = true;
    };
    ssh.client = {
      enable = true;
      workConfig.enable = true;
    };
  };
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "ben";
  home.homeDirectory = "/Users/ben";

  home.packages = with pkgs; [
    pfetch-rs
    neofetch
  ];
  home.sessionVariables = {
    EDITOR = "nvim";
    PAGER = "less";
    PF_INFO = "ascii title os kernel pkgs wm shell editor";
    KUBECONFIG = "${config.sops.secrets.workkube.path}";
  };
  home.file = {
    ".config/karabiner/karabiner.json".source = ./files/karabiner.json;
    ".config/yabai/mac-focus-space-SIP.sh".source = ./files/mac-focus-space-SIP.sh;
    ".config/yabai/mac-move-space-SIP.sh".source = ./files/mac-move-space-SIP.sh;
  };
}

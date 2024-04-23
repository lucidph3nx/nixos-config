{ config, pkgs, nixpkgs-unstable, ... }:

{
  imports =
  [
    # ../../modules/home-manager/scripts.nix
  ];
  sysDefaults = {
    terminal = "${pkgs.kitty}/bin/kitty";
  };
  # my own modules
  # homeManagerModules = {
  #   prospect-mail.enable = true;
  #   teams-for-linux.enable = true;
  #   # Enable home automation stuff as device should be in the home
  #   homeAutomation.enable = true;
  #   ssh.client.enable = true;
  #   ssh.client.workConfig.enable = true;
  # };
  home = {
    username = "ben";
    homeDirectory = "/home/ben";
  };
  home.stateVersion = "23.11"; # Do Not Touch!
  
  home.packages = with pkgs; [
    gimp # temp for troubleshooting
    picard
    # cinnamon.nemo
  ];

  home.sessionVariables = {
    KUBECONFIG = "/home/ben/.config/kube/config-home";
    PAGER = "less";
  };


  programs.neovim = {
    enable = true;
    defaultEditor = true;
    package = pkgs.neovim-unwrapped;
    # package = pkgs.neovim-nightly;
    plugins = with pkgs.vimPlugins; [
      {
        plugin = nvim-autopairs;
        type = "lua";
        config =
          /*
          lua
          */
          ''
          -- ${pkgs.neovim-unwrapped}
          -- ${nvim-autopairs}
          require('nvim-autopairs').setup{}
          '';
      }
    ];
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

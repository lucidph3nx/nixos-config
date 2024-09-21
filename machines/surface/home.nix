{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence
  ];
  # my own modules
  homeManagerModules = {
    firefox.hideUrlbar = true;
    hyprland.enable = true;
    sway.enable = true;
    obsidian.enable = true;
    homeAutomation.enable = true;
    ssh.client.enable = true;
    ssh.client.workConfig.enable = true;
  };
  home = {
    username = "ben";
    homeDirectory = "/home/ben";
  };
  home.stateVersion = "24.05"; # Do Not Touch!

  home.persistence."/persist/home/ben" = {
    directories = [
      ".local/share/nix"
      ".local/share/nvim"
      ".local/state"
      ".cache"
      ".ssh"
      "code"
      "documents"
      "music"
      ".config/syncthing"
    ];
    files = [
      # ".zsh_history"
    ];
    allowOther = true;
  };

  home.packages = with pkgs; [
    gimp # temp for troubleshooting
    picard
    # cinnamon.nemo
  ];

  home.sessionVariables = {
    # KUBECONFIG = "/home/ben/.config/kube/config-home";
    PAGER = "less";
  };
}

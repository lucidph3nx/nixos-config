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
    hyprland.enable = true;
    sway.enable = true;
    waybar.fontSize = "14px";
  };
  home = {
    username = "ben";
    homeDirectory = "/home/ben";
  };
  home.stateVersion = "24.05"; # Do Not Touch!

  home.persistence."/persist/home/ben" = {
    directories = [
      ".local/share/nix"
      ".local/state"
      ".cache"
      "code"
      "documents"
      "music"
    ];
    files = [
      # ".zsh_history"
    ];
    allowOther = true;
  };

  home.packages = with pkgs; [
    gimp # temp for troubleshooting
    # cinnamon.nemo
  ];

  home.sessionVariables = {
    # KUBECONFIG = "/home/ben/.config/kube/config-home";
    PAGER = "less";
  };
}

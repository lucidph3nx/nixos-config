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
    desktopEnvironment.enable = false;
    guiApps.enable = false; # console only vm
    # firefox.enable = true; # testing removing and readding
    # firefox.hideUrlbar = true;
    # prospect-mail.enable = true;
    # teams-for-linux.enable = true;
    # hyprland.wallpaperResolution = "1680x1050";
    # # Enable home automation stuff as device should be in the home
    homeAutomation.enable = false;
    ssh.client.enable = true;
  };
  home = {
    username = "ben";
    homeDirectory = "/home/ben";
  };
  home.stateVersion = "24.05"; # Do Not Touch!

    home.persistence."/persist/home/ben" = {
    allowOther = true;
    directories = [
      # {
      #   directory = ".local/share/Steam";
      #   method = "symlink";
      # }
      ".local/share/lutris"
      ".local/share/nix"
      ".local/share/nvim"
      ".local/share/vulkan"
      ".local/state"
      ".cache"
      ".ssh"
      "code"
      "documents"
      # these should be with the hm modules
      # but give compile errors on darwin
      ".config/syncthing"
      ".terraform.d"
    ];
  };

  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    settings = {
      program_options = {
        menu = "flat";
        file_manager = "xdg-open";
      };
      device_config = [
        # ignore hardware os switch
        {
          id_uuid = "55AA-6922";
          ignore = true;
        }
      ];
    };
    tray = "auto";
  };

  # home.packages = with pkgs; [
  #   gimp # temp for troubleshooting
  #   picard
  #   # cinnamon.nemo
  # ];

  home.sessionVariables = {
    # KUBECONFIG = "/home/ben/.config/kube/config-home";
    PAGER = "less";
  };
}

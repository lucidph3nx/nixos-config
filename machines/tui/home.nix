{
  config,
  pkgs-stable,
  pkgs-master,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence
  ];
  # my own modules
  # setTheme = "github-light";
  setTheme = "onedark";
  homeManagerModules = {
    calibre.enable = true;
    darktable.enable = true;
    firefox.hideUrlbar = true;
    homeAutomation.enable = true;
    wallpaper.resolution = "2880x1800";
    hyprland = {
      enable = true;
      lockTimeout = 300; # lock after 5 minutes
      screenTimeout = 600; # screen off after 10 minutes
      suspendTimeout = 900; # suspend after 15 minutes
    };
    hyprlock = {
      enable = true;
      oled = true;
    };
    libreoffice.enable = true;
    obsidian.enable = true;
    picard.enable = true;
    plexamp.enable = true;
    thunderbird.enable = true;
    ssh.client.enable = true;
    sway.enable = true;
  };
  home = {
    username = "ben";
    homeDirectory = "/home/ben";
  };
  home.stateVersion = "24.05"; # Do Not Touch!

  home.persistence."/persist/home/ben" = {
    allowOther = true;
    directories = [
      {
        directory = ".local/share/Steam";
        method = "symlink";
      }
      ".local/share/lutris"
      ".local/share/nix"
      ".local/share/nvim"
      ".local/share/vulkan"
      ".local/state"
      ".cache"
      ".ssh"
      "code"
      "documents"
      "music"
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
    };
    tray = "auto";
  };

  wayland.windowManager.hyprland.settings.monitor = [
    "eDP-1,2880x1800@120.00000,0x0,1.5"
  ];

  home.packages = with pkgs; [
    gimp
    # cinnamon.nemo
  ];

  home.sessionVariables = {
    PAGER = "less";
  };
}

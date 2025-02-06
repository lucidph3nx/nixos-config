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
  setTheme = "everforest";
  homeManagerModules = {
    calibre.enable = true;
    darktable.enable = true;
    firefox.hideUrlbar = true;
    homeAutomation.enable = true;
    wallpaper = {
      variant = "enso";
      resolution = "2880x1800";
    };
    hyprland = {
      enable = true;
      lockTimeout = {
        enable = false;
      };
      screenTimeout = {
        enable = true;
        duration = 600; # screen off after 10 minutes
      };
      suspendTimeout = {
        enable = true;
        duration = 900; # suspend after 15 minutes
      };
    };
    hyprlock = {
      enable = true;
      oled = true;
    };
    libreoffice.enable = true;
    obsidian.enable = true;
    picard.enable = true;
    plexamp.enable = true;
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
      ".local/share/PrismLauncher"
      ".local/share/nix"
      ".local/share/nvim"
      ".local/share/vulkan"
      ".local/share/applications" # where steam puts its .desktop files for games
      ".local/share/icons/hicolor" # where steam puts its icons
      ".local/state"
      ".cache"
      ".ssh"
      "code"
      "documents"
      "music"
      # these should be with the hm modules
      # but give compile errors on darwin
      ".config/syncthing"
    ];
  };
  home.activation = {
    # ensure these empty directories exist
    emptyDirs = ''
      mkdir -p /home/ben/downloads
    '';
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
    pkgs-stable.prismlauncher # open source minecraft launcher
    # cinnamon.nemo
  ];

  home.sessionVariables = {
    PAGER = "less";
  };
}

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
  setTheme = "everforest";
  homeManagerModules = {
    anki.enable = true;
    calibre.enable = true;
    cura.enable = true;
    darktable.enable = true;
    firefox.hideUrlbar = true;
    homeAutomation.enable = true;
    wallpaper = {
      variant = "enso";
    };
    hyprland = {
      enable = true;
      disableWorkspaceAnimations = true;
    };
    hyprlock.enable = true;
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
      # {
      #   directory = ".local/share/Steam";
      #   method = "symlink";
      # }
      ".local/share/lutris"
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
      "games"
    ];
  };
  home.activation = {
    # ensure these empty directories exist
    emptyDirs = ''
      mkdir -p /home/ben/downloads
    '';
  };

  home.packages = with pkgs; [
    gimp
    # cinnamon.nemo
    # retro gaming
    mednafen
    pcsx2
  ];

  wayland.windowManager.hyprland.settings.monitor = [
    "DP-3,5120x1440@239.76Hz,0x0,1"
  ];

  home.sessionVariables = {
    PAGER = "less";
    MEDNAFEN_HOME = "${config.xdg.configHome}/mednafen";
  };
}

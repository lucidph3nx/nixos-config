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
    wallpaper = {
      variant = "enso";
    };
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
      ".local/share/vulkan"
      ".local/share/applications" # where steam puts its .desktop files for games
      ".local/share/icons/hicolor" # where steam puts its icons
      ".local/state"
      ".cache"
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

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
    ags.enable = true;
    anki.enable = true;
    calibre.enable = true;
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
    libreoffice.enable = true;
    obsidian.enable = true;
    picard.enable = true;
    plexamp.enable = true;
    ssh.client.enable = true;
    sway.enable = true;
    waybar.mouseBattery = true;
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
      "games"
      # these should be with the hm modules
      # but give compile errors on darwin
      ".config/syncthing"
      ".terraform.d"
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

  home.packages = with pkgs; [
    # https://github.com/NixOS/nixpkgs/issues/325896
    # I also seem to need to run it with QT_QPA_PLATFORM=xcb
    pkgs-stable.cura
    gimp
    # cinnamon.nemo
    # retro gaming
    mednafen
    pcsx2
  ];

  wayland.windowManager.hyprland.settings.monitor = [
    "DP-3,highrr,5120x1440,1"
  ];

  home.sessionVariables = {
    PAGER = "less";
    MEDNAFEN_HOME = "${config.xdg.configHome}/mednafen";
  };
}

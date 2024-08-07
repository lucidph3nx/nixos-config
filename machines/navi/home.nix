{
  config,
  nixpkgs-stable,
  nixpkgs-master,
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
    libreoffice.enable = true;
    obsidian.enable = true;
    calibre.enable = true;
    teams-for-linux.enable = true;
    # Enable home automation stuff as device should be in the home
    homeAutomation.enable = true;
    sway.enable = true;
    hyprland.enable = true;
    waybar.displayportOnly = true;
    waybar.mouseBattery = true;
    ssh.client.enable = true;
    ssh.client.workConfig.enable = true;
  };
  home = {
    username = "ben";
    homeDirectory = "/home/ben";
  };
  home.stateVersion = "23.11"; # Do Not Touch!

  home.persistence."/persist/home/ben" = {
    allowOther = true;
    directories = [
      {
        directory = ".local/share/Steam";
        method = "symlink";
      }
      ".local/share/mpd"
      ".local/share/nvim"
      ".local/share/vulkan"
      ".local/share/zsh"
      ".local/share/nix"
      ".local/state"
      ".cache"
      ".ssh"
      "code"
      "documents"
      "music"
      "pictures/darktable"
      # these should be with the hm modules
      # but give compile errors on darwin
      ".asdf/installs"
      ".asdf/plugins"
      ".config/Bitwarden CLI"
      ".config/calibre"
      ".config/darktable"
      ".config/github-copilot"
      ".config/nvim/spell"
      ".config/obsidian"
      ".config/Plexamp"
      ".config/syncthing"
      ".config/teams-for-linux"
      ".mozilla/firefox"
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

  home.packages = with pkgs; [
    # https://github.com/NixOS/nixpkgs/issues/325896
    nixpkgs-stable.cura
    gimp
    picard
    darktable
    # cinnamon.nemo
    # retro gaming
    mednafen
    pcsx2
  ];

  home.sessionVariables = {
    PAGER = "less";
    MEDNAFEN_HOME = "${config.xdg.configHome}/mednafen";
  };

  xdg.mimeApps.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

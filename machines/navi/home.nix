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
    obsidian.enable = true;
    calibre.enable = true;
    prospect-mail.enable = true;
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
      # ".local/share/Steam"
      ".local/share/mpd"
      ".local/share/nvim"
      ".local/share/vulkan"
      ".local/share/zsh"
      ".local/state"
      ".cache"
      ".ssh"
      "code"
      "documents"
      "music"
      # these should be with the hm modules
      # but give compile errors on darwin
      ".asdf/installs"
      ".asdf/plugins"
      ".config/Bitwarden CLI"
      ".config/Prospect Mail"
      ".config/calibre"
      ".config/github-copilot"
      ".config/nvim/spell"
      ".config/obsidian"
      ".config/teams-for-linux"
      ".config/syncthing"
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
       { id_uuid = "55AA-6922"; ignore = true; }
      ];
    };
    tray = "auto";
  };

  home.packages = with pkgs; [
    gimp # temp for troubleshooting
    picard
    cura
    # cinnamon.nemo
  ];

  home.sessionVariables = {
    PAGER = "less";
  };

  xdg.mimeApps.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

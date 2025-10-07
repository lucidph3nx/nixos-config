{
  config,
  lib,
  ...
}:
{
  imports = [
    ./secrets.nix
  ];
  options = {
    nx.services.syncthing.enable =
      lib.mkEnableOption "Set up syncthing (includes documents folder)"
      // {
        default = false;
      };
    nx.services.syncthing.obsidian.enable = lib.mkEnableOption "Set up syncthing obsidian folder" // {
      default = false;
    };
    nx.services.syncthing.calibre.enable = lib.mkEnableOption "Set up syncthing calibre folder" // {
      default = false;
    };
    nx.services.syncthing.music.enable = lib.mkEnableOption "Set up syncthing music folder" // {
      default = false;
    };
    nx.services.syncthing.music.path = lib.mkOption {
      type = lib.types.str;
      default = "/persist/home/ben/music/";
      description = "location for music folder";
    };
    nx.services.syncthing.photos.enable = lib.mkEnableOption "Set up syncthing photos folder" // {
      default = false;
    };
    nx.services.syncthing.darktable.enable = lib.mkEnableOption "Set up syncthing darktable folder" // {
      default = false;
    };
  };
  config = lib.mkIf config.nx.services.syncthing.enable {
    services.syncthing = {
      enable = true;
      user = "ben";

      # if you don't put the database and config somewhere stable
      # syncthing will panic every startup and rebuild the database or maybe remove and re-add the folder?
      # either way, its horrible and slow and this fixes it.
      databaseDir = "/persist/cache/syncthing";
      configDir = "/persist/home/ben/.config/syncthing";
      overrideDevices = true;
      settings = {
        devices = {
          "k8s" = {
            id = "FZVNVGQ-6TJDJLG-DRWSAWW-AQLKQM7-U36GWON-7ZQ7CLF-32MBYFN-SFHWHAX";
          };
          "nas0" = {
            id = "7LANRKO-RRMWROL-PDMCTJX-WKSPOKO-LS3K35O-CJEMX7O-MHHIURW-GSF6FAS";
          };
        };
        folders = {
          "obsidian" = lib.mkIf config.nx.services.syncthing.obsidian.enable {
            id = "hgl5u-yejsp";
            devices = [ "k8s" ];
            path = "/persist/home/ben/documents/obsidian";
          };
          "calibre" = lib.mkIf config.nx.services.syncthing.calibre.enable {
            id = "bny6u-oz6gf";
            devices = [ "nas0" ];
            path = "/persist/home/ben/documents/calibre";
          };
          "music" = lib.mkIf config.nx.services.syncthing.music.enable {
            id = "dmuif-nefck";
            devices = [ "nas0" ];
            path = config.nx.services.syncthing.music.path;
          };
          "photos" = lib.mkIf config.nx.services.syncthing.photos.enable {
            id = "4ghtf-4leca";
            devices = [ "nas0" ];
            path = "/persist/home/ben/pictures/photos";
          };
          "darktable" = lib.mkIf config.nx.services.syncthing.darktable.enable {
            id = "x7g7m-4z7qg";
            devices = [ "nas0" ];
            path = "/persist/home/ben/.config/darktable";
          };
        };
        options.urAccepted = -1;
      };
    };
    # don't start syncthing until network is online
    systemd.services.syncthing = {
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
    };
    # network ports for syncthing
    networking.firewall = {
      allowedTCPPorts = [
        22000
      ];
      allowedUDPPorts = [
        22000
        21027
      ];
    };
    system.activationScripts.documentsFolder = lib.mkIf config.nx.services.syncthing.enable ''
      mkdir -p /home/ben/documents
      chown ben:users /home/ben/documents
    '';
    system.activationScripts.picturesFolder = lib.mkIf config.nx.services.syncthing.enable ''
      mkdir -p /home/ben/pictures
      chown ben:users /home/ben/pictures
    '';
    system.activationScripts.obsidianFolder = lib.mkIf config.nx.services.syncthing.obsidian.enable ''
      mkdir -p /home/ben/documents/obsidian
      chown ben:users /home/ben/documents/obsidian
    '';
    system.activationScripts.musicFolder = lib.mkIf config.nx.services.syncthing.music.enable ''
      mkdir -p /home/ben/music
      chown ben:users /home/ben/music
    '';
    system.activationScripts.photosFolder = lib.mkIf config.nx.services.syncthing.photos.enable ''
      mkdir -p /home/ben/pictures/photos
      chown ben:users /home/ben/pictures/photos
    '';
    system.activationScripts.darktableFolder = lib.mkIf config.nx.services.syncthing.darktable.enable ''
      mkdir -p /home/ben/.config/darktable
      chown ben:users /home/ben/.config/darktable
    '';

    # Set env for OBSIDIAN_VAULT_PATH when obsidian folder is enabled
    home-manager.users.ben.home.sessionVariables = lib.mkIf config.nx.services.syncthing.obsidian.enable {
      OBSIDIAN_VAULT_PATH = "/home/ben/documents/obsidian";
    };

    # persist the syncthing config with home-manager impermanence module
    home-manager.users.ben.home.persistence."/persist/home/ben" = {
      allowOther = true;
      directories = [
        ".config/syncthing"
      ];
    };
  };
}

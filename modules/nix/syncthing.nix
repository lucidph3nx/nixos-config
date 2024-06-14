{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    nixModules.syncthing.enable =
      lib.mkEnableOption "Set up syncthing";
    nixModules.syncthing.obsidian.enable =
      lib.mkEnableOption "Set up syncthing obsidian folder";
    nixModules.syncthing.music.enable =
      lib.mkEnableOption "Set up syncthing music folder";
  };
  config = lib.mkIf config.nixModules.syncthing.enable {
    services.syncthing = {
      enable = true;
      user = "ben";
      dataDir = "/home/ben/documents";
      configDir = "/home/ben/.config/syncthing";
      overrideDevices = true;
      settings = {
        devices = {
          "k8s" = {id = "FZVNVGQ-6TJDJLG-DRWSAWW-AQLKQM7-U36GWON-7ZQ7CLF-32MBYFN-SFHWHAX";};
          "nas0" = {id = "7LANRKO-RRMWROL-PDMCTJX-WKSPOKO-LS3K35O-CJEMX7O-MHHIURW-GSF6FAS";};
        };
        folders = {
          "obsidian" = lib.mkIf config.nixModules.syncthing.obsidian.enable {
            id = "hgl5u-yejsp";
            devices = ["k8s"];
            path = "/home/ben/documents/obsidian";
          };
          "music" = lib.mkIf config.nixModules.syncthing.music.enable {
            id = "dmuif-nefck";
            devices = ["nas0"];
            # path = "/home/ben/music";
            path = "/persist/home/ben/music";
          };
        };
        options.urAccepted = -1;
      };
      extraFlags = [
        "--no-default-folder"
      ];
    };
    networking.firewall = {
      allowedTCPPorts = [
        # 8384 # This would be to make the web interface available on the network
        22000
      ];
      allowedUDPPorts = [
        22000
        21027
      ];
    };
    system.activationScripts.documentsFolder = lib.mkIf config.nixModules.syncthing.enable ''
      mkdir -p /home/ben/documents
      chown ben:users /home/ben/documents
    '';
    system.activationScripts.obsidianFolder = lib.mkIf config.nixModules.syncthing.obsidian.enable ''
      mkdir -p /home/ben/documents/obsidian
      chown ben:users /home/ben/documents/obsidian
    '';
    system.activationScripts.musicFolder = lib.mkIf config.nixModules.syncthing.music.enable ''
      mkdir -p /home/ben/music
      chown ben:users /home/ben/music
    '';
  };
}

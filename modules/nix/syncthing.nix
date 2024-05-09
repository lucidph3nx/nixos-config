{ config, pkgs, lib, ... }:

{
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
      overrideDevices = true;
      settings = {
        devices = {
          "k8s" = { id = "FZVNVGQ-6TJDJLG-DRWSAWW-AQLKQM7-U36GWON-7ZQ7CLF-32MBYFN-SFHWHAX"; };
          "nas0" = { id = "7LANRKO-RRMWROL-PDMCTJX-WKSPOKO-LS3K35O-CJEMX7O-MHHIURW-GSF6FAS"; };
        };
        options.urAccepted = -1;
      };
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
    # Syncthing makes this Sync folder when enabled, its anoying and I don't use it.
    system.activationScripts.removeSyncFolder = lib.mkIf config.nixModules.syncthing.enable '' 
      rm -r /home/ben/Sync
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

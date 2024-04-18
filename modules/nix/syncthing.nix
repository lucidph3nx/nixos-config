{ config, pkgs, lib, ... }:

{
  options = {
    nixModules.syncthing.enable =
      lib.mkEnableOption "Set up syncthing";
  };
  config = lib.mkIf config.nixModules.syncthing.enable {
    services.syncthing = {
      enable = true;
      user = "ben";
      dataDir = "/home/ben/Documents";
      overrideDevices = true;
      overrideFolders = true;
      settings = {
        devices = {
          k8s = { id = "FZVNVGQ-6TJDJLG-DRWSAWW-AQLKQM7-U36GWON-7ZQ7CLF-32MBYFN-SFHWHAX"; };
          nas0 = { id = "7LANRKO-RRMWROL-PDMCTJX-WKSPOKO-LS3K35O-CJEMX7O-MHHIURW-GSF6FAS"; };
        };
        folders = {
          "obsidian-vaults" = {
            path = "/home/ben/documents/obsidian";
            devices = [ "k8s" ];
          };
          # "music" = {
          #   path = "/home/ben/music";
          #   devices = [ "nas0" ];
          # };
        };
        options.urAccepted = -1;
      };
    };
    networking.firewall = {
      allowedTCPPorts = [
        # 8384
        22000 
      ];
      allowedUDPPorts = [
        22000
        21027
      ];
    };
  };
}

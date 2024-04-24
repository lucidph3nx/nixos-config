{ lib, ... }:
let
  nasServerIP = "10.87.1.200";
in 
{
  options = {
    nixModules.nfs-mounts.enable =
      lib.mkEnableOption "Set up local NFS mounts";
  };
  config = {
    fileSystems."/nfs/3d" = {
      device = "${nasServerIP}:/volume1/3d";
      fsType = "nfs";
    };
    fileSystems."/nfs/ben-backup" = {
      device = "${nasServerIP}:/volume1/ben-backup";
        fsType = "nfs";
      };
    fileSystems."/nfs/books" = {
      device = "${nasServerIP}:/volume1/Books";
      fsType = "nfs";
    };
    fileSystems."/nfs/downloads" = {
      device = "${nasServerIP}:/volume1/downloads";
      fsType = "nfs";
    };
    fileSystems."/nfs/learn" = {
      device = "${nasServerIP}:/volume1/learn";
      fsType = "nfs";
    };
    fileSystems."/nfs/longhorn-backups" = {
      device = "${nasServerIP}:/volume1/longhorn-backups";
      fsType = "nfs";
    };
    fileSystems."/nfs/movies" = {
      device = "${nasServerIP}:/volume1/Films";
      fsType = "nfs";
    };
    fileSystems."/nfs/music" = {
      device = "${nasServerIP}:/volume1/Music";
      fsType = "nfs";
    };
    fileSystems."/nfs/tv" = {
      device = "${nasServerIP}:/volume1/TV-Series";
      fsType = "nfs";
    };
    fileSystems."/nfs/software" = {
      device = "${nasServerIP}:/volume1/software";
      fsType = "nfs";
    };
  };
}

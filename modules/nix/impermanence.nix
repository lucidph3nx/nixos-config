{
  config,
  lib,
  ...
}: {
  options = {
    nixModules.impermanence.enable =
      lib.mkEnableOption "Code to support impermanence"
      // {
        default = true;
      };
  };
  config = lib.mkIf config.nixModules.impermanence.enable {
    # # https://github.com/nix-community/impermanence/issues/229
    # boot.initrd.systemd.suppressedUnits = ["systemd-machine-id-commit.service"];
    # systemd.suppressedSystemUnits = ["systemd-machine-id-commit.service"];

    # Wipe the disk on each boot
    boot.initrd.postDeviceCommands =
      lib.mkAfter
      /*
      bash
      */
      ''
        mkdir /btrfs_tmp
        mount /dev/root_vg/root /btrfs_tmp
        if [[ -e /btrfs_tmp/root ]]; then
            mkdir -p /btrfs_tmp/old_roots
            timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
            mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
        fi

        delete_subvolume_recursively() {
            IFS=$'\n'
            for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
                delete_subvolume_recursively "/btrfs_tmp/$i"
            done
            btrfs subvolume delete "$1"
        }

        for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +14); do
            delete_subvolume_recursively "$i"
        done

        btrfs subvolume create /btrfs_tmp/root
        umount /btrfs_tmp
      '';

    # things to persist
    fileSystems."/persist".neededForBoot = true;
    environment.persistence."/persist/system" = {
      hideMounts = true;
      directories = [
        "/var/log"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/sops-nix"
        "/var/lib/systemd/coredump"
        "/etc/NetworkManager/system-connections"
        "/etc/ssh"
      ];
      files = [
        "/etc/machine-id"
      ];
    };
    # without these, you will get errors the first time after install
    system.activationScripts.persistDirs = ''
      mkdir -p /persist/system/var/log
      mkdir -p /persist/system/var/lib/nixos
      mkdir -p /persist/cache
      chown -R ben:users /persist/cache
      mkdir -p /persist/home/ben
      mkdir -p /persist/home/ben/.ssh
      mkdir -p /persist/home/ben/.local/share/Steam
      chown -R ben:users /persist/home/ben
    '';
    # ensure these empty directories exist
    system.activationScripts.emptyDirs = ''
      mkdir -p /home/ben/downloads
      chown -R ben:users /home/ben/downloads
    '';
    # needed for impermanance in home-manager
    programs.fuse.userAllowOther = true;
  };
}

{
  pkgs,
  pkgs-stable,
  pkgs-master,
  inputs,
  config,
  lib,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    (import ./disko.nix {device = "/dev/nvme0n1";})
    inputs.disko.nixosModules.default
    ../../modules/nix
  ];

  nixModules = {
    isLaptop = true;
    sops = {
      ageKeys.enable = true;
      generalSecrets.enable = true;
      signingKeys.enable = true;
      homeSSHKeys.enable = true;
      kubeconfig.enable = true;
    };
    syncthing = {
      enable = true;
      obsidian.enable = true;
      calibre.enable = true;
      music.enable = true;
    };
    input-remapper.enable = true;
  };

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

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
  boot.kernel.sysctl."net.core.rmem_max" = 2500000;

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

  networking = {
    hostName = "tui";
    networkmanager.enable = true;
    hosts = {
    };
  };
  # allow portforward of 443
  security.wrappers = {
    ssh = {
      owner = "root";
      group = "root";
      capabilities = "cap_net_bind_service=+eip";
      source = "${pkgs.openssh}/bin/ssh";
    };
  };

  # no password for sudo
  security.sudo.wheelNeedsPassword = false;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ben = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.ben_hashed_password.path;
    description = "ben";
    extraGroups = ["networkmanager" "wheel" "uinput" "openrazer"];
    shell = pkgs.zsh;
  };

  # needed for impermanance in home-manager
  programs.fuse.userAllowOther = true;
  # home-manager is awesome
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
      inherit pkgs-stable;
      inherit pkgs-master;
    };
    users = {
      ben.imports = [
        ./home.nix
        ../../modules
      ];
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    brightnessctl
    cheese
    exfat
    fastfetch
    ffmpeg
    gamescope
    inkscape
    lsof
    lutris-unwrapped
    mangohud
    ntfs3g
    parted
    polychromatic
    protontricks
    protonup
    qpwgraph
    shotcut
    solvespace
    usbutils
    wev
  ];
  hardware.openrazer = {
    enable = true;
    # doesn't work, always sends notifications of 0%, probably the devices fault
    batteryNotifier.enable = false;
  };

  environment.sessionVariables = {
    # for kube
    KUBECONFIG = "${config.sops.secrets.homekube.path}";
  };

  fonts.fontDir.enable = true;
  fonts.packages = [
    (pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];})
    pkgs.noto-fonts
  ];

  programs.sway = {
    enable = true;
    extraPackages = []; # I don't need foot etc bundled
  };
  programs.hyprland = {
    enable = true;
  };
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
    ];
    wlr.enable = lib.mkForce true; #TODO: figure out why hyprland conflicts with this
  };

  # add blocking
  networking.nameservers = [
    "127.0.0.1"
  ];
  services.blocky = {
    enable = true;
    settings = {
      port = "127.0.0.1:53";
      bootstrapDns = {
        upstream = "https://one.one.one.one/dns-query";
        ips = [ "1.1.1.1" "1.0.0.1" ];
      };
      upstreams.groups.default = [
        "tcp-tls:one.one.one.one:853"
        "tcp-tls:dns.quad9.net:853"
      ];
      blocking = {
        blackLists = {
          suspicious = [
            "https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt"
            "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts"
            "https://v.firebog.net/hosts/static/w3kbl.txt"
          ];
          ads = [
            "https://adaway.org/hosts.txt"
            "https://v.firebog.net/hosts/AdguardDNS.txt"
            "https://v.firebog.net/hosts/Admiral.txt"
            "https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt"
            "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
            "https://v.firebog.net/hosts/Easylist.txt"
            "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext"
            "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/UncheckyAds/hosts"
            "https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts"
          ];
          trackers = [
            "https://v.firebog.net/hosts/Easyprivacy.txt"
            "https://v.firebog.net/hosts/Prigent-Ads.txt"
            "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.2o7Net/hosts"
            "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt"
            "https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt"
          ];
          misc = [
            "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt"
            "https://osint.digitalside.it/Threat-Intel/lists/latestdomains.txt"
            "https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt"
            "https://v.firebog.net/hosts/Prigent-Crypto.txt"
            "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts"
            "https://phishing.army/download/phishing_army_blocklist_extended.txt"
            "https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-malware.txt"
            "https://v.firebog.net/hosts/RPiList-Malware.txt"
            "https://v.firebog.net/hosts/RPiList-Phishing.txt"
            "https://raw.githubusercontent.com/Spam404/lists/master/main-blacklist.txt"
            "https://raw.githubusercontent.com/AssoEchap/stalkerware-indicators/master/generated/hosts"
          ];
        };
        whiteLists = {
          suspicious = [
            "https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt"
          ];
          ads = [
            "https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt"
          ];
          trackers = [
            "https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt"
          ];
          misc = [
            "https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt"
          ];
        };
        clientGroupsBlock.default = [
          "suspicious"
          "ads"
          "trackers"
          "misc"
        ];
      };
    };
  };

  # key remapping
  services.kanata = {
    enable = true;
    keyboards.main = {
      devices = ["/dev/input/by-path/platform-i8042-serio-0-event-kbd"];
      extraDefCfg = ''
        process-unmapped-keys yes
      '';
      config =
        /*
        lisp
        */
        ''
          (defsrc
            ;;caps a s d f j k l ;
            caps
          )
          (defvar
            tap-time 150
            hold-time 200
          )
          (defalias
          ;; tap caps lock as esc, hold as left control
          escctrl (tap-hold-release $tap-time $hold-time esc lctl)
          mod-a (tap-hold-release $tap-time $hold-time a lmet)
          mod-s (tap-hold-release $tap-time $hold-time s lalt)
          mod-d (tap-hold-release $tap-time $hold-time d lsft)
          mod-f (tap-hold-release $tap-time $hold-time f lctl)
          mod-j (tap-hold-release $tap-time $hold-time j rctl)
          mod-k (tap-hold-release $tap-time $hold-time k rsft)
          mod-l (tap-hold-release $tap-time $hold-time l ralt)
          mod-; (tap-hold-release $tap-time $hold-time ; lmet) ;; note, I map rmet to a maori char mod key in hyprland
          )
          (deflayer base
            ;;@escctrl @mod-a @mod-s @mod-d @mod-f @mod-j @mod-k @mod-l @mod-;
            @escctrl
          )
        '';
    };
  };

  # List services that you want to enable:
  services.dbus.implementation = "broker";
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # sound
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
  };
  security.rtkit.enable = true;

  # cups for printing
  services.printing.enable = true;

  # power management
  services.power-profiles-daemon.enable = true;

  # gaming
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  programs.steam = {
    enable = true;
    gamescopeSession.enable = false;
    protontricks.enable = true;
  };
  programs.gamemode.enable = true;
  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/ben/.steam/root/compatibilitytools.d";
  };

  services.udisks2 = {
    enable = true;
    mountOnMedia = true;
  };

  # device specific syncthing config
  sops.secrets.tui-cert-pem = {
    owner = "ben";
    mode = "0600";
    sopsFile = ../../secrets/syncthingKeys.yaml;
  };
  sops.secrets.tui-key-pem = {
    owner = "ben";
    mode = "0600";
    sopsFile = ../../secrets/syncthingKeys.yaml;
  };
  services.syncthing.cert = config.sops.secrets.tui-cert-pem.path;
  services.syncthing.key = config.sops.secrets.tui-key-pem.path;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}

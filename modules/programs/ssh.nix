{
  config,
  lib,
  pkgs,
  pkgs-stable,
  ...
}: let
  homeDir = config.home-manager.users.ben.home.homeDirectory;
  cloudflaredBlock = {
                    # waiting for https://github.com/NixOS/nixpkgs/issues/370185
    proxyCommand = "${pkgs-stable.cloudflared}/bin/cloudflared access ssh --hostname %h.$CLOUDFLARED_DOMAIN";
    user = "ben";
    port = 22;
    identityFile = "${homeDir}/.ssh/lucidph3nx-ed25519";
  };
in {
  options = {
    nx.programs.ssh.enable =
      lib.mkEnableOption "Configuration to support outbound ssh"
      // {
        default = true;
      };
  };

  config = lib.mkIf config.nx.programs.ssh.enable {
    home-manager.users.ben = {
      home.packages = with pkgs; [
        # waiting for https://github.com/NixOS/nixpkgs/issues/370185
        pkgs-stable.cloudflared
      ];
      programs.ssh = {
        enable = true;
        matchBlocks = {
          "*" = {
            # don't ask to check host key for new hosts
            extraOptions = {
              StrictHostKeyChecking = "accept-new";
            };
          };
          "node0" = cloudflaredBlock;
          "node1" = cloudflaredBlock;
          "node2" = cloudflaredBlock;
          "node3" = cloudflaredBlock;
          "nas0" = {
            hostname = "10.87.1.200";
            port = 220;
            user = "ben";
            identityFile = "${homeDir}/.ssh/lucidph3nx-ed25519";
          };
          "usg" = {
            hostname = "10.87.0.1";
            port = 22;
            user = "ben";
            # until unifi supports ed25519
            identityFile = "${homeDir}/.ssh/lucidph3nx-rsa";
            extraOptions = {
              PubkeyAcceptedKeyTypes = "+ssh-rsa";
            };
          };
        };
      };
      home.persistence."/persist/home/ben" = {
        allowOther = true;
        directories = [
          ".ssh"
        ];
      };
      # a script to open ssh connections to all nodes
      home.file.".local/scripts/home.ssh.allNodes" = {
        executable = true;
        text =
          /*
          sh
          */
          ''
            #!/bin/sh
            kitty ssh node0 &
            kitty ssh node1 &
            kitty ssh node2 &
            kitty ssh node3
          '';
      };
    };
    # ssh secrets
    sops.secrets = let
      sopsFile = ./secrets/ssh.sops.yaml;
    in {
      "ssh/lucidph3nx-ed25519" = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.ssh/lucidph3nx-ed25519";
        sopsFile = sopsFile;
      };
      "ssh/lucidph3nx-ed25519.pub" = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.ssh/lucidph3nx-ed25519.pub";
        sopsFile = sopsFile;
      };
      "ssh/lucidph3nx-rsa" = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.ssh/lucidph3nx-rsa";
        sopsFile = sopsFile;
      };
      "ssh/lucidph3nx-rsa.pub" = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.ssh/lucidph3nx-rsa.pub";
        sopsFile = sopsFile;
      };
      "config/cloudflared_domain" = {
        owner = "ben";
        mode = "0600";
        sopsFile = sopsFile;
      };
    };
    environment.sessionVariables = {
      CLOUDFLARED_DOMAIN = "$(cat ${config.sops.secrets."config/cloudflared_domain".path})";
    };
    system.activationScripts.sshKeysFolderPermissions = ''
      mkdir -p /home/ben/.ssh
      chown ben:users /home/ben/.ssh
    '';
  };
}

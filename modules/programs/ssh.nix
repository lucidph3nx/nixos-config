{
  config,
  lib,
  pkgs,
  ...
}: let
  homeDir = config.home-manager.users.ben.home.homeDirectory;
  cloudflaredBlock = {
    proxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h.$SECRET_DOMAIN";
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
      home.packages = with pkgs; [cloudflared];
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
    };
  };
}

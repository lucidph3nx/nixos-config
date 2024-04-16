{ config, osConfig, pkgs, inputs, lib, ... }:

let 
  homeDir = config.home.homeDirectory;
  cloudflaredBlock = {
    proxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h.$SECRET_DOMAIN";
    user = "ben";
    port = 22;
    identityFile = "${homeDir}/.ssh/lucidph3nx-ed25519";
  };
in
{
  options = {
    homeManagerModules.ssh.client.enable =
      lib.mkEnableOption "enables a client style ssh config intended for workstations";
    homeManagerModules.ssh.workConfig.enable =
      lib.mkEnableOption "Add my work ssh config";
  };
  config = lib.mkIf config.homeManagerModules.ssh.client.enable {
    home.packages = with pkgs; [ cloudflared ];
    programs.ssh = {
      enable = true;
      # includes = lib.mkIf osConfig.nixModules.sops.workSecrets.enable
      #   [ "${osConfig.sops.templates.ssh-config.path}" ];
      matchBlocks = {
        "*" = {
          # don't ask to check host key for new hosts
          extraOptions  = {
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
          extraOptions  = {
            PubkeyAcceptedKeyTypes = "+ssh-rsa";
          };
        };
      };
    };
  };
}

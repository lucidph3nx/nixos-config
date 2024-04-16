{ config, pkgs, inputs, lib, ... }:

let 
  homeDir = config.home.homeDirectory;
in
{
  # SSH hosts that are part of my hopelab infra
  programs.ssh.matchBlocks = {
    "node0" = {
      proxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname ssh.$SECRET_DOMAIN/#h";
      user = "ben";
      port = 22;
      identityFile = "${homeDir}/.ssh/lucidph3nx-ed25519";
    };
    "node1" = {
      proxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname ssh.$SECRET_DOMAIN/%h";
      user = "ben";
      port = 22;
      identityFile = "${homeDir}/.ssh/lucidph3nx-ed25519";
    };
  };
}

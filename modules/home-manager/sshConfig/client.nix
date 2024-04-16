{ config, pkgs, inputs, lib, ... }:

let 
  homeDir = config.home.homeDirectory;
in
{
  options = {
    homeManagerModules.ssh.client.enable =
      lib.mkEnableOption "enables a client style ssh config intended for workstations";
  };
  config = lib.mkIf config.homeManagerModules.ssh.client.enable {
    home.packages = with pkgs; [ cloudflared ];
    programs.ssh = {
      enable = true;
      matchBlocks = {
        "node0" = {
          proxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname ssh.$SECRET_DOMAIN/node0";
          user = "ben";
          port = 22;
          identityFile = "${homeDir}/.ssh/lucidph3nx-ed25519";
        };
      };
    };
  };
}

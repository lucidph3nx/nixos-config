{ config, pkgs, inputs, lib, ... }:

let 
  homeDir = config.home.homeDirectory;
in
{
  options = {
    homeManagerModules.ssh.proxymac =
      lib.mkEnableOption "should these ssh sessions go via proxy macbook";
  };
  config = {
    # SSH hosts for work @ jarden
    programs.ssh.matchBlocks = {
      "mac" = {
        hostname = "10.93.149.41";
        user = "ben";
        port = 22;
        # this needs to be rsa for it to work
        # correctly as a jumpbox to other rsa-only devices
        identityFile = "${homeDir}/.ssh/jarden-rsa";
        extraOptions  = {
          PubkeyAcceptedKeyTypes = "+ssh-rsa";
        };
      };
      "build3w build3w.fnzsl.com" = {
        hostname = "build3w.fnzsl.com";
        user = "bsherman";
        identityFile = "${homeDir}/.ssh/jarden-rsa";
        extraOptions  = {
          PubkeyAcceptedKeyTypes = "+ssh-rsa";
        };
        proxyJump = lib.mkIf config.homeManagerModules.ssh.proxymac "mac";
      };
      "prod-17w appserv17w-m.fnzsl.com" = {
        hostname = "appserv17w-m.fnzsl.com";
        user = "bsherman";
        identityFile = "${homeDir}/.ssh/jarden-rsa";
        extraOptions  = {
          PubkeyAcceptedKeyTypes = "+ssh-rsa";
        };
        proxyJump = lib.mkIf config.homeManagerModules.ssh.proxymac "mac";
      };
    };
  };
}

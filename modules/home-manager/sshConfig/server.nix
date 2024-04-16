{ config, pkgs, inputs, lib, ... }:

{
  options = {
    homeManagerModules.ssh.server.enable =
      lib.mkEnableOption "enables a client style ssh config intended for remote servers";
  };
  config = lib.mkIf config.homeManagerModules.ssh.server.enable {
    programs.ssh = {
      enable = true;
    };
  };
}

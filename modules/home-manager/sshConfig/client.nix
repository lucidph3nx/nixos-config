{ config, pkgs, inputs, lib, ... }:

let 
  homeDir = config.home.homeDirectory;
in
{
  imports = [ ./home-ops.nix ];
  options = {
    homeManagerModules.ssh.client.enable =
      lib.mkEnableOption "enables a client style ssh config intended for workstations";
  };
  config = lib.mkIf config.homeManagerModules.ssh.client.enable {
    home.packages = with pkgs; [ cloudflared ];
    programs.ssh = {
      enable = true;
    };
  };
}

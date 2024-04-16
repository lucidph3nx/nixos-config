{ config, pkgs, inputs, lib, ... }:

{
  imports = [ ./matchBlocks/home-ops.nix ];
  options = {
    homeManagerModules.ssh.client.enable =
      lib.mkEnableOption "enables a client style ssh config intended for workstations";
  };
  config = lib.mkIf config.homeManagerModules.ssh.client.enable {
    home.packages = with pkgs; [ cloudflared ];
    programs.ssh = {
      enable = true;
      matchBlocks = {
        "*" = {
          # don't ask to check host key for new hosts
          extraOptions  = {
            StrictHostKeyChecking = "accept-new";
          };
        };
      };
    };
  };
}

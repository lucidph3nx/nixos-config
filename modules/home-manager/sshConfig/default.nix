{ config, pkgs, inputs, lib, ... }: {
  imports = [
    ./client.nix
    ./server.nix
  ];

  config = {
    homeManagerModules = {
      ssh.client.enable = lib.mkDefault false;
      ssh.client.workConfig.enable = lib.mkDefault false;
      ssh.server.enable = lib.mkDefault false;
    };
  };
}

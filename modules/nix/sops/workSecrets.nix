{ config, pkgs, inputs, lib, ... }:

let
  workSecret = {
    owner = "ben";
    mode = "0600";
    sopsFile = ../../../secrets/workSecrets.yaml;
  };
in
{
  options = {
    nixModules.sops.workSecrets.enable =
      lib.mkEnableOption "secrets for work";
  };
  config = lib.mkIf config.nixModules.sops.workSecrets.enable {
    sops.secrets.rsa = workSecret;
    sops.secrets.rsa-pub = workSecret;
    sops.secrets.build3w = workSecret;
    sops.secrets.prod-17w = workSecret;

    sops.templates.ssh-config.content = 
    # with config.sops.secrets;
    ''
      Host mac
        HostName 10.93.149.41
        Port 22
        User ben
        IdentityFile ${config.sops.secrets.rsa-pub.path}
        PubkeyAcceptedKeyTypes +ssh-rsa

      Match host build3w,${config.sops.secrets.build3w} exec "[[ '%L' != 'm1mac' ]]"
        ProxyJump mac
      Host build3w ${config.sops.secrets.build3w}
        Hostname ${config.sops.secrets.build3w}
        User bsherman
        IdentityFile ${config.sops.secrets.rsa-pub.path}
        PubkeyAcceptedKeyTypes +ssh-rsa
        ServerAliveInterval 30

      Match host prod-17w,${config.sops.secrets.prod-17w} exec "[[ '%L' != 'm1mac' ]]"
        ProxyJump mac
      Host prod-17w ${config.sops.secrets.prod-17w}
        Hostname ${config.sops.secrets.prod-17w}
        User bsherman
        IdentityFile ${config.sops.secrets.rsa-pub.path}
        PubkeyAcceptedKeyTypes +ssh-rsa
        ServerAliveInterval 30
    '';
  };
}

{ config, pkgs, lib, inputs, ... }: {
  imports = [
    ./generalSecrets.nix
    ./signingKeys.nix
    ./homeSSHKeys.nix
    ./workSSH.nix
    ./kubeconfig.nix
    inputs.sops-nix.nixosModules.sops
  ];
  config = {
    nixModules = {
      sops.generalSecrets.enable = lib.mkDefault false;
      sops.signingKeys.enable = lib.mkDefault false;
      sops.homeSSHKeys.enable = lib.mkDefault false;
      sops.workSSH.enable = lib.mkDefault false;
      sops.kubeconfig.enable = lib.mkDefault false;
    };
    # sops defaults
    sops = {
      defaultSopsFile = ../../../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";
      age = {
        keyFile = "/var/lib/sops-nix/key.txt";
        generateKey = true;
        sshKeyPaths = [ "/etc/ssh/nix-ed25519" ];
      };
    };
    # seems necessary to get sops-nix to work with impermanance 🤷
    systemd.services.force-rebuild-sops-hack = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = ''
          /run/current-system/activate
        '';
        Type = "oneshot";
        Restart = "on-failure"; # because oneshot
        RestartSec = "10s";
      };
    }; 
  };
}

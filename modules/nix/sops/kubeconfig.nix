{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  options = {
    nixModules.sops.kubeconfig.enable =
      lib.mkEnableOption "Set up kube config";
  };
  config = lib.mkIf config.nixModules.sops.kubeconfig.enable {
    sops.secrets = let
      sopsFile = ../../../secrets/kubeconfig.yaml;
    in {
      homekube = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.config/kube/config";
        sopsFile = sopsFile;
      };
    };
    system.activationScripts.kubeConfigFolderPermissions = ''
      mkdir -p /home/ben/.config/kube
      chown ben:users /home/ben/.config
      chown ben:users /home/ben/.config/kube
    '';
  };
}

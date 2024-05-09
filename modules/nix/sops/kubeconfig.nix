{ config, lib, pkgs, inputs, ... }:

{
  options = {
    nixModules.sops.kubeconfig.enable =
      lib.mkEnableOption "Set up kube config";
  };
  config = lib.mkIf config.nixModules.sops.kubeconfig.enable {
    sops.secrets = 
    let 
      sopsFile = ../../../secrets/kubeconfig.yaml;
    in
    {
      homekube = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.config/kube/config-home";
        sopsFile = sopsFile;
      };
      workkube = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.config/kube/config-work";
        sopsFile = sopsFile;
      };
      wfhkube = {
        owner = "ben";
        mode = "0600";
        path = "/home/ben/.config/kube/config-wfh";
        sopsFile = sopsFile;
      };
    };
  };
}

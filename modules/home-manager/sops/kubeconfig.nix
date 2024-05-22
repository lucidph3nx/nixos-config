{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  options = {
    homeManagerModules.sops.kubeconfig.enable =
      lib.mkEnableOption "Set up kube config";
  };
  config = lib.mkIf config.homeManagerModules.sops.kubeconfig.enable {
    sops.secrets = let
      sopsFile = ../../../secrets/kubeconfig.yaml;
    in {
      homekube = {
        path = "${config.home.homeDirectory}/.config/kube/config-home";
        sopsFile = sopsFile;
      };
      workkube = {
        path = "${config.home.homeDirectory}/.config/kube/config-work";
        sopsFile = sopsFile;
      };
      wfhkube = {
        path = "${config.home.homeDirectory}/kube/config-wfh";
        sopsFile = sopsFile;
      };
    };
  };
}

{
  config,
  pkgs,
  lib,
  ...
}: let
  kubeDir = "${config.home-manager.users.ben.home.homeDirectory}/.config/kube";
in {
  options = {
    nx.programs.kubetools.enable =
      lib.mkEnableOption "enables some cli tools for managing kubernetes"
      // {
        default = true;
      };
  };
  config = lib.mkIf config.nx.programs.kubetools.enable {
    home-manager.users.ben = {
      home.packages = with pkgs; [
        kubectl
        kubernetes-helm
        fluxcd
      ];
      home.sessionVariables = {
        KUBECONFIG = "${kubeDir}/config";
      };
    };
    sops.secrets.kubeconfig = {
      owner = "ben";
      mode = "0600";
      path = "${kubeDir}/config";
      sopsFile = ./secrets/kubeconfig.sops.yaml;
    };
    system.activationScripts.kubeConfigFolderPermissions = ''
      mkdir -p ${kubeDir}
      chown ben:users /home/ben/.config
      chown ben:users ${kubeDir}
    '';
  };
}

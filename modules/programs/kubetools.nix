{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
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
        kubelogin-oidc
        kubelogin
        fluxcd
        krew
      ];
    };
  };
}

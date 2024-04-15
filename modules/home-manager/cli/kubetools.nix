{ config, pkgs, inputs, lib, ... }: {
  options = {
    home-manager-modules.kubetools.enable =
      lib.mkEnableOption "enables kubetools";
  };
  config = lib.mkIf config.home-manager-modules.kubetools.enable {
    home.packages = with pkgs; [ 
      kubectl
      kubernetes-helm
      fluxcd
      krew
    ];
  };
}

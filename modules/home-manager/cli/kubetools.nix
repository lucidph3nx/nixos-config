{ config, pkgs, inputs, lib, ... }: {
  options = {
    homeManagerModules.kubetools.enable =
      lib.mkEnableOption "enables kubetools";
  };
  config = lib.mkIf config.homeManagerModules.kubetools.enable {
    home.packages = with pkgs; [ 
      kubectl
      kubernetes-helm
      fluxcd
      krew
    ];
  };
}

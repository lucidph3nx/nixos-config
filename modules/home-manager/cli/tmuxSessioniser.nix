{ config, pkgs, inputs, lib, ... }: {
  options = {
    home-manager-modules.tmuxSessioniser.enable =
      lib.mkEnableOption "enables tmuxSessioniser";
  };
  config = lib.mkIf config.home-manager-modules.tmuxSessioniser.enable {
    # Dependencies for the scripts to work
    home.packages = with pkgs; [ 
      kubectl
      helm
      fluxcd
      krew
    ];
  };
}

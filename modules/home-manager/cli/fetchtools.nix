{ config, pkgs, inputs, lib, ... }: {
  options = {
    homeManagerModules.neofetch.enable =
      lib.mkEnableOption "enables neofetch";
    homeManagerModules.pfetch.enable =
      lib.mkEnableOption "enables pfetch";
  };
  config = {
    home.packages = with pkgs; [ 
      (lib.mkIf config.homeManagerModules.neofetch.enable neofetch)
      (lib.mkIf config.homeManagerModules.pfetch.enable pfetch-rs)
    ];
    home.sessionVariables = {
      PF_INFO = lib.mkIf config.homeManagerModules.pfetch.enable 
        "ascii title os kernel pkgs wm shell editor";
    };
  };
}

{ config, pkgs, inputs, lib, ... }:

{
  options = {
    home-manager-modules.zathura.enable =
      lib.mkEnableOption "enables zathura";
  };
  config = lib.mkIf config.home-manager-modules.zathura.enable {
    programs.zathura = {
      enable = true;
    };
    xdg.mimeApps.defaultApplications = {
      "application/pdf" = [ "org.pwmt.zathura.desktop" ];
    };
  };
}

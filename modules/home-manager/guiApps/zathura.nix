{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  options = {
    homeManagerModules.zathura.enable =
      lib.mkEnableOption "enables zathura";
  };
  config = lib.mkIf config.homeManagerModules.zathura.enable {
    programs.zathura = {
      enable = true;
    };
    xdg.mimeApps.defaultApplications = {
      "application/pdf" = ["org.pwmt.zathura.desktop"];
    };
  };
}

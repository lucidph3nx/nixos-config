{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  options = {
    homeManagerModules.libreoffice.enable =
      lib.mkEnableOption "enables libreoffice";
  };
  config = lib.mkIf config.homeManagerModules.libreoffice.enable {
    home.packages = with pkgs; [
      libreoffice
    ];
    xdg.mimeApps.defaultApplications = {
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = ["writer.desktop"];
    };
  };
}

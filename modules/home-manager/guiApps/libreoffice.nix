{
  config,
  pkgs,
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
      # language
      hunspell
      hunspellDicts.en_GB-large
    ];
    xdg.mimeApps.defaultApplications = {
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = ["writer.desktop"];
    };
    home.persistence."/persist/home/ben" = {
      directories = [
        ".config/libreoffice"
      ];
    };
    wayland.windowManager.hyprland.settings = lib.mkIf (config.homeManagerModules.hyprland.enable) {
      windowrulev2 = [
        # prevent libreoffice-writer from fullscreening
        "syncfullscreen 0, class:(libreoffice-writer)"
      ];
    };
  };
}

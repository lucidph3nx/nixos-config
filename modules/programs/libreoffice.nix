{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    nx.programs.libreoffice.enable =
      lib.mkEnableOption "enables libreoffice"
      // {
        default = false;
      };
  };
  config = lib.mkIf config.nx.programs.libreoffice.enable {
    home-manager.users.ben = {
      home.packages = with pkgs; [
        libreoffice
        # language/spellchecker
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
      wayland.windowManager.hyprland.settings = lib.mkIf (config.home-manager.users.ben.wayland.windowManager.hyprland.enable) {
        windowrulev2 = [
          # prevent libreoffice-writer from fullscreening
          "syncfullscreen 0, class:(libreoffice-writer)"
        ];
      };
    };
  };
}

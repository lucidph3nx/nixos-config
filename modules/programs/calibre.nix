{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    nx.programs.calibre.enable =
      lib.mkEnableOption "enables calibre"
      // {
        default = false;
      };
  };
  config = lib.mkIf config.nx.programs.calibre.enable {
    home-manager.users.ben = {
      home.packages = [
        pkgs.calibre
      ];
      home.persistence."/persist/home/ben" = {
        directories = [
          ".config/calibre"
        ];
      };
      xdg.mimeApps.defaultApplications = {
        "application/epub+zip" = "calibre-ebook-viewer.desktop";
      };
    };
  };
}

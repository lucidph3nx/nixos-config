{
  config,
  lib,
  ...
}: {
  options = {
    homeManagerModules.thunderbird.enable =
      lib.mkEnableOption "enables thunderbird";
  };
  config = lib.mkIf config.homeManagerModules.thunderbird.enable {
    programs.thunderbird = {
      enable = true;
      profiles.personal = {
        isDefault = true;
      };
      settings = {
        # Sort them by the newest reply in thread.
        "mailnews.sort_threads_by_root" = true;
        "app.update.auto" = false;
        "privacy.donottrackheader.enabled" = true;
      };
    };
    xdg.mimeApps.defaultApplications = {
      "x-scheme-handler/mailto" = ["thunderbird.desktop"];
      "x-scheme-handler/mid" = ["thunderbird.desktop"];
      "message/rfc822" = ["thunderbird.desktop"];
    };
    home.persistence."/persist/home/ben" = {
      directories = [
        ".cache/thunderbird"
        ".thunderbird"
      ];
    };
  };
}

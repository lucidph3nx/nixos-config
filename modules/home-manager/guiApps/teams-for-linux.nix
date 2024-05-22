{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    homeManagerModules.teams-for-linux.enable =
      lib.mkEnableOption "enables teams-for-linux";
  };
  config = lib.mkIf config.homeManagerModules.teams-for-linux.enable {
    home.packages = with pkgs; [teams-for-linux];

    # teams-for-linux does not seem to read config files that are symlinks
    home.file = {
      ".config/teams-for-linux/config.json" = {
        text =
          /*
          js
          */
          ''
            {
              "spellCheckerLanguages":["en-NZ"],
              "optInTeamsV2":"true",
              "customCSSLocation":"custom.css"
            }
          '';
      };
    };
    home.file = {
      ".config/teams-for-linux/custom.css" = {
        text =
          /*
          css
          */
          ''
            html, body {
              font-family: JetBrains Mono, monospace !important;
            }
          '';
      };
    };

    xdg.desktopEntries = lib.mkIf pkgs.stdenv.isLinux {
      teams-for-linux = {
        name = "Teams";
        genericName = "teams";
        exec = ''teams-for-linux %U'';
        icon = "teams";
        categories = ["Network" "Chat" "InstantMessaging"];
        mimeType = ["x-scheme-handler/msteams"];
      };
    };
  };
}

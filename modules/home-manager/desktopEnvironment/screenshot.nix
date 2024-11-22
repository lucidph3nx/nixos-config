{
  config,
  pkgs,
  lib,
  ...
}: let
  theme = config.theme;
in {
  options = {
    homeManagerModules.screenshot.enable =
      lib.mkEnableOption "enables screenshot utils"
      // {
        default = true;
      };
  };
  config = lib.mkIf config.homeManagerModules.screenshot.enable {
    home.file.".local/scripts/application.grim.screenshotToClipboard" = {
      executable = true;
      text = ''
        #!/bin/sh
        ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp -c "${theme.green}FF" -b '${theme.bg0}80')" - | ${pkgs.wl-clipboard}/bin/wl-copy
      '';
    };
    home.file.".local/scripts/application.grim.screenshotToFile" = {
      executable = true;
      text = ''
        #!/bin/sh
        mkdir -p "$HOME/pictures/screenshots"
        ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp -c "${theme.green}FF" -b '${theme.bg0}80')" "$HOME/pictures/screenshots/$(date '+%y%m%d_%H-%M-%S').png"
      '';
    };
    home.file.".local/scripts/application.grim.fullScreenshotToFile" = {
      executable = true;
      text = ''
        #!/bin/sh
        sleep 0.2 # wait for the ui to move if done from command palette
        mkdir -p "$HOME/pictures/screenshots"
        ${pkgs.grim}/bin/grim "$HOME/pictures/screenshots/$(date '+%y%m%d_%H-%M-%S').png"
      '';
    };
  };
}

{ config, pkgs, lib, ... }:

{
  options = {
    homeManagerModules.teams-for-linux.enable =
      lib.mkEnableOption "enables teams-for-linux";
  };
  config = lib.mkIf config.homeManagerModules.teams-for-linux.enable {
    home.packages = with pkgs; [ teams-for-linux ];
    xdg.desktopEntries = lib.mkIf pkgs.stdenv.isLinux {
        teams-for-linux = {
          name = "Teams";
          genericName = "teams";
          exec = ''teams-for-linux --spellCheckerLanguages="en-NZ" %U'';
          icon = "teams";
          categories = [ "Network" "Chat" "InstantMessaging"];
          mimeType = ["x-scheme-handler/msteams"];
        };
    };
  };
}

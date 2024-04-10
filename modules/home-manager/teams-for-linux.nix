{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [ teams-for-linux ];
  xdg.desktopEntries = {
      teams-for-linux = {
        name = "Teams";
        genericName = "teams";
        exec = "teams-for-linux --spellCheckerLanguages='en-NZ' %U";
        icon = "teams";
        categories = [ "Network" "Chat" "InstantMessaging" "Application"];
        mimeType = ["x-scheme-handler/msteams"];
      };
  };
}

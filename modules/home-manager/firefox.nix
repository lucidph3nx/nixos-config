{ config, pkgs, ... }:

{
  programs.firefox = {
  	enable = true;
    nativeMessagingHosts [
      pkgs.tridactyl-native
    ];
    profiles.ben = {
      extensions with pkgs.inputs.firefox-addons; = [
        augmented-steam
        bitwarden
        decentraleyes
        multi-account-containers
        protondb-for-steam
        reddit-enhancement-suite
        sponsorblock
        temporary-containers
        tridactyl
        ublock-origin
      ]
    }
  };
    xdg.mimeApps.defaultApplications = {
    "text/html" = [ "firefox.desktop" ];
    "text/xml" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
  };
}

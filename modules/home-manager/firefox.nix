{ config, pkgs, inputs, ... }:

{
  programs.firefox = {
  	enable = true;
    # not in 23.11
    # nativeMessagingHosts = [
    #   pkgs.tridactyl-native
    # ];
    profiles.ben = {
      id = 0;
      name = "ben";
      isDefault = true;
      settings = {
        "signon.rememberSignons" = false; # Disable built-in password manager
      };
      extensions = with inputs.firefox-addons.packages.${pkgs.system}; [
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
      ];
    };
  };
  home.packages = [
    pkgs.tridactyl-native
  ];
    xdg.mimeApps.defaultApplications = {
    "text/html" = [ "firefox.desktop" ];
    "text/xml" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
  };
}

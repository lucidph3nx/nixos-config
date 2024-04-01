{ config, pkgs, inputs, ... }:

{
  home.file = {
    # workarounds
    # https://github.com/NixOS/nixpkgs/issues/281710#issuecomment-1987263584
    ".mozilla/native-messaging-hosts" = {
      recursive = true;
      source = let
        nativeMessagingHosts = with pkgs; [
          tridactyl-native
        ];
      in pkgs.runCommandLocal "native-messaging-hosts" { } ''
        mkdir $out
        for ext in ${toString nativeMessagingHosts}; do
            ln -sLt $out $ext/lib/mozilla/native-messaging-hosts/*
        done
      '';
    };
    ".config/tridactyl/tridactylrc".source = ./files/tridactyl-config;
    ".config/tridactyl/themes/everforest.css".source = ./files/tridactyl-style;
    ".config/tridactyl/home.html".source = ./files/tridactyl-homepage;
    ".mozilla/firefox/ben/chrome/userChrome.css".source = ./files/firefox-userChrome;
    ".mozilla/firefox/ben/chrome/userContent.css".source = ./files/firefox-userContent;
  };
  programs.firefox = {
  	enable = true;
    # not in 23.11
    # nativeMessagingHosts.packages = [
    #   pkgs.tridactyl-native
    # ];
    profiles.ben = {
      id = 0;
      name = "ben";
      isDefault = true;
      settings = {
        "signon.rememberSignons" = false; # Disable built-in password manager
        "browser.startup.homepage" = "~/.config/tridactyl/home.html"; # custom homepage
        "browser.compactmode.show" = true;
        "browser.uidensity" = 1; # enable compact mode
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "ui.systemUsesDarkTheme" = 1; # force dark theme
        "extensions.pocket.enabled" = false;
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
    xdg.mimeApps.defaultApplications = {
    "text/html" = [ "firefox.desktop" ];
    "text/xml" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
  };
}

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
        "browser.uiCustomization.state" = "{\"placements\":{\"widget-overflow-fixed-list\":[],\"unified-extensions-area\":[\"_testpilot-containers-browser-action\",\"jid1-bofifl9vbdl2zq_jetpack-browser-action\",\"_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action\"],\"nav-bar\":[\"back-button\",\"forward-button\",\"stop-reload-button\",\"customizableui-special-spring1\",\"urlbar-container\",\"customizableui-special-spring2\",\"save-to-pocket-button\",\"downloads-button\",\"fxa-toolbar-menu-button\",\"ublock0_raymondhill_net-browser-action\",\"sponsorblocker_ajay_app-browser-action\",\"unified-extensions-button\",\"_c607c8df-14a7-4f28-894f-29e8722976af_-browser-action\"],\"toolbar-menubar\":[\"menubar-items\"],\"TabsToolbar\":[\"tabbrowser-tabs\",\"new-tab-button\",\"alltabs-button\"],\"PersonalToolbar\":[\"personal-bookmarks\"]},\"seen\":[\"_testpilot-containers-browser-action\",\"jid1-bofifl9vbdl2zq_jetpack-browser-action\",\"ublock0_raymondhill_net-browser-action\",\"_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action\",\"_c607c8df-14a7-4f28-894f-29e8722976af_-browser-action\",\"sponsorblocker_ajay_app-browser-action\",\"developer-button\"],\"dirtyAreaCache\":[\"unified-extensions-area\",\"nav-bar\",\"TabsToolbar\"],\"currentVersion\":20,\"newElementCount\":3}";
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

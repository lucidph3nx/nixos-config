{ config, pkgs, lib, ... }:
let
  bugfixedFirefox = pkgs.firefox-esr-unwrapped // { requireSigning = false; allowAddonSideload = true; };
in
{
  options = {
    homeManagerModules.firefox.enable =
      lib.mkEnableOption "enables firefox";
  };
  config = lib.mkIf config.homeManagerModules.firefox.enable {
    programs.firefox = {
      enable = true;
      package = pkgs.wrapFirefox bugfixedFirefox {
        nixExtensions = [
          (pkgs.fetchFirefoxAddon {
            name = "sponsorblock";
            url = "https://addons.mozilla.org/firefox/downloads/file/4202411/sponsorblock-5.4.29.xpi";
            hash = "sha256-7Xqc8cyQNylMe5/dgDOx1f2QDVmz3JshDlTueu6AcSg=";
          })
          (pkgs.fetchFirefoxAddon {
            name = "ublock-origin";
            url = "https://addons.mozilla.org/firefox/downloads/file/4198829/ublock_origin-1.54.0.xpi";
            hash = "sha256-l5cWCQgZFxD/CFhTa6bcKeytmSPDCyrW0+XjcddZ5E0=";
          })
          (pkgs.fetchFirefoxAddon {
            name = "tridactyl";
            url = "https://addons.mozilla.org/firefox/downloads/file/4261352/tridactyl_vim-1.24.1.xpi";
            hash = "";
           })
        ];
      };
      profiles = {
        main = {
          id = 0;
          name = "ben";
          isDefault = true;
          settings = {
            "signon.rememberSignons" = false; # Disable built-in password manager
            "browser.startup.homepage" = "~/.config/tridactyl/home.html"; # custom homepage
            "browser.compactmode.show" = true;
            "browser.uidensity" = 1; # enable compact mode
            "browser.uiCustomization.state" = "{\"placements\":{\"widget-overflow-fixed-list\":[],\"unified-extensions-area\":[\"_testpilot-containers-browser-action\",\"jid1-bofifl9vbdl2zq_jetpack-browser-action\",\"_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action\"],\"nav-bar\":[\"back-button\",\"forward-button\",\"stop-reload-button\",\"customizableui-special-spring1\",\"urlbar-container\",\"customizableui-special-spring2\",\"save-to-pocket-button\",\"downloads-button\",\"fxa-toolbar-menu-button\",\"ublock0_raymondhill_net-browser-action\",\"sponsorblocker_ajay_app-browser-action\",\"unified-extensions-button\",\"_c607c8df-14a7-4f28-894f-29e8722976af_-browser-action\"],\"toolbar-menubar\":[\"menubar-items\"],\"TabsToolbar\":[\"tabbrowser-tabs\",\"new-tab-button\",\"alltabs-button\"],\"PersonalToolbar\":[\"personal-bookmarks\"]},\"seen\":[\"_testpilot-containers-browser-action\",\"jid1-bofifl9vbdl2zq_jetpack-browser-action\",\"ublock0_raymondhill_net-browser-action\",\"_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action\",\"_c607c8df-14a7-4f28-894f-29e8722976af_-browser-action\",\"sponsorblocker_ajay_app-browser-action\",\"developer-button\"],\"dirtyAreaCache\":[\"unified-extensions-area\",\"nav-bar\",\"TabsToolbar\"],\"currentVersion\":20,\"newElementCount\":3}";
            "browser.aboutConfig.showWarning" = false;
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            "ui.systemUsesDarkTheme" = 1; # force dark theme
            "extensions.pocket.enabled" = false;

            # dubious performance enhancements
            "network.buffer.cache.size" = 524288; # 512KB (default is 32 kB)
            "network.http.max-connections" = 1800; # default is 900
            "network.http.max-persistent-connections-per-server" = 12; # default is 6
            "network.http.max-urgent-start-excessive-connections-per-host" = 10; # default is 3
            "network.http.pacing.requests.burst" = 32; # default is 10
            "network.http.pacing.requests.min-parallelism" = 10; # default is 6
            "network.websocket.max-connections" = 400; # default is 200
            "network.ssl_tokens_cache_capacity" = 32768; # more TLS token caching (fast reconnects) (default is 2048)
            "image.mem.decode_bytes_at_a_time" = 65536; # 64KB (default is 16KB)

            # Enable installing non signed extensions
            "extensions.langpacks.signatures.required" = false;
            "xpinstall.signatures.required" = false;

            # Enable userChrome editor (Ctrl+Shift+Alt+I)
            "devtools.chrome.enabled" = true;
            "devtools.debugger.remote-enabled" = true;
          };
        };
      };
    };
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
    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      MOZ_DISABLE_RDD_SANDBOX = "1";
    };
    xdg.mimeApps.defaultApplications = {
      "text/html" = [ "firefox.desktop" ];
      "text/xml" = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
    };
  };
}

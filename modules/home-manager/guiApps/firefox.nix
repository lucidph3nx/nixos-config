{ config, pkgs, lib, ... }:
let
  bugfixedFirefox = pkgs.firefox-unwrapped // { requireSigning = false; allowAddonSideload = true; };
  homeDir = config.home.homeDirectory;
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
            name = "augmented-steam";
            url = "https://addons.mozilla.org/firefox/downloads/file/4264122/augmented_steam-3.1.1.xpi";
            hash = "sha256-b6syDKr3Cm1NFfiyZiFngL632iRocbm+GkgOaKDrny8=";
           })
          (pkgs.fetchFirefoxAddon {
            name = "bitwarden";
            url = "https://addons.mozilla.org/firefox/downloads/file/4263752/bitwarden_password_manager-2024.4.1.xpi";
            hash = "sha256-G6HmbLmk7jv4CoH8MTSLBBYjhUVdKwL5kCRz45MdlpM=";
           })
          (pkgs.fetchFirefoxAddon {
            name = "decentraleyes";
            url = "https://addons.mozilla.org/firefox/downloads/file/4255788/decentraleyes-2.0.19.xpi";
            hash = "sha256-EF1lv4GJ1SclFkfQRScVxXJa9gZfumfNCBhxkKrkqY8=";
           })
          (pkgs.fetchFirefoxAddon {
            name = "dont-track-me-google";
            url = "https://addons.mozilla.org/firefox/downloads/file/4132891/dont_track_me_google1-4.28.xpi";
            hash = "sha256-JbyQAF1vKNUxgu9Ix+/LunKxmM5nzx8HR9vSPUMHiyY=";
           })
          (pkgs.fetchFirefoxAddon {
            name = "multi-account-containers";
            url = "https://addons.mozilla.org/firefox/downloads/file/4186050/multi_account_containers-8.1.3.xpi";
            hash = "sha256-M+3ZjQ/H1H+jEPIU+JfOTf4miw+GjJ1/MrTKUFc9+Fw=";
           })
          (pkgs.fetchFirefoxAddon {
            name = "i-still-dont-care-about-cookies";
            url = "https://addons.mozilla.org/firefox/downloads/file/4216095/istilldontcareaboutcookies-1.1.4.xpi";
            hash = "sha256-yt6yRiLTuaK4K/QwgkL9gCVGsSa7ndFOHqZvKqIGZ5U=";
           })
          (pkgs.fetchFirefoxAddon {
            name = "protondb-for-steam";
            url = "https://addons.mozilla.org/firefox/downloads/file/4195217/protondb_for_steam-2.1.0.xpi";
            hash = "sha256-PteCRQOjGERQMmsJpx0IbCvfzgTWOEyjsC8M+ADbWFI=";
           })
          (pkgs.fetchFirefoxAddon {
            name = "reddit-comments-for-youtube";
            url = "https://addons.mozilla.org/firefox/downloads/file/4217855/reddit_comments_for_youtube-3.1.2.xpi";
            hash = "sha256-h8IIEJiSXog953IaoHXMpcb68Sroi/uF7gy2YEaAEiM=";
           })
          (pkgs.fetchFirefoxAddon {
            name = "reddit-enhancement-suite";
            url = "https://addons.mozilla.org/firefox/downloads/file/4257183/reddit_enhancement_suite-5.24.4.xpi";
            hash = "sha256-hs9pWMVGBLnx3MfpJcHBi98+0qjgmGCJZFJ+azWdBXw=";
           })
          (pkgs.fetchFirefoxAddon {
            name = "sponsorblock";
            url = "https://addons.mozilla.org/firefox/downloads/file/4202411/sponsorblock-5.4.29.xpi";
            hash = "sha256-7Xqc8cyQNylMe5/dgDOx1f2QDVmz3JshDlTueu6AcSg=";
          })
          (pkgs.fetchFirefoxAddon {
            name = "tampermonkey";
            url = "https://addons.mozilla.org/firefox/downloads/file/4250678/tampermonkey-5.1.0.xpi";
            hash = "sha256-k5p7BXPMeV6uLeoBexh92xNdF3i/JvHFEyFWdFEqBAs=";
           })
          (pkgs.fetchFirefoxAddon {
            name = "temporary-containers";
            url = "https://addons.mozilla.org/firefox/downloads/file/3723251/temporary_containers-1.9.2.xpi";
            hash = "sha256-M0CgjCm+fIO9D+o/wn/eceRgikUy2TIRS0OappDn7cA=";
           })
          (pkgs.fetchFirefoxAddon {
            name = "tridactyl";
            url = "https://addons.mozilla.org/firefox/downloads/file/4261352/tridactyl_vim-1.24.1.xpi";
            hash = "sha256-q2P+FVRHHCgPI0QJOTFy/FjhuyylJ/QynZg7AoBz4Zw=";
           })
          (pkgs.fetchFirefoxAddon {
            name = "ublock-origin";
            url = "https://addons.mozilla.org/firefox/downloads/file/4198829/ublock_origin-1.54.0.xpi";
            hash = "sha256-l5cWCQgZFxD/CFhTa6bcKeytmSPDCyrW0+XjcddZ5E0=";
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
            "browser.startup.homepage" = "${homeDir}/.config/tridactyl/home.html"; # custom homepage
            "browser.compactmode.show" = true;
            "browser.uidensity" = 1; # enable compact mode
            "browser.uiCustomization.state" = "{\"placements\":{\"widget-overflow-fixed-list\":[],\"unified-extensions-area\":[\"nixos_sponsorblock-browser-action\",\"nixos_decentraleyes-browser-action\",\"nixos_i-still-dont-care-about-cookies-browser-action\",\"nixos_multi-account-containers-browser-action\",\"nixos_reddit-comments-for-youtube-browser-action\",\"nixos_tampermonkey-browser-action\"],\"nav-bar\":[\"back-button\",\"forward-button\",\"stop-reload-button\",\"customizableui-special-spring1\",\"urlbar-container\",\"customizableui-special-spring2\",\"save-to-pocket-button\",\"downloads-button\",\"fxa-toolbar-menu-button\",\"nixos_ublock-origin-browser-action\",\"unified-extensions-button\",\"nixos_temporary-containers-browser-action\",\"nixos_bitwarden-browser-action\"],\"toolbar-menubar\":[\"menubar-items\"],\"TabsToolbar\":[\"firefox-view-button\",\"tabbrowser-tabs\",\"new-tab-button\",\"alltabs-button\"],\"PersonalToolbar\":[\"personal-bookmarks\"]},\"seen\":[\"nixos_bitwarden-browser-action\",\"nixos_decentraleyes-browser-action\",\"nixos_i-still-dont-care-about-cookies-browser-action\",\"nixos_multi-account-containers-browser-action\",\"nixos_reddit-comments-for-youtube-browser-action\",\"nixos_tampermonkey-browser-action\",\"nixos_temporary-containers-browser-action\",\"nixos_ublock-origin-browser-action\",\"nixos_sponsorblock-browser-action\",\"developer-button\"],\"dirtyAreaCache\":[\"unified-extensions-area\",\"nav-bar\",\"TabsToolbar\",\"toolbar-menubar\",\"PersonalToolbar\"],\"currentVersion\":19,\"newElementCount\":3}";
            "browser.aboutConfig.showWarning" = false;
            "browser.tabs.firefox-view" = false;
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
      ".mozilla/firefox/main/chrome/userChrome.css".source = ./files/firefox-userChrome;
      ".mozilla/firefox/main/chrome/userContent.css".source = ./files/firefox-userContent;
    };
    # home.sessionVariables = {
    #   MOZ_ENABLE_WAYLAND = "1";
    #   MOZ_DISABLE_RDD_SANDBOX = "1";
    # };
    xdg.mimeApps.defaultApplications = {
      "text/html" = [ "firefox.desktop" ];
      "text/xml" = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
    };
  };
}

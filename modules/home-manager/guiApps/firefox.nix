{ config, pkgs, lib, ... }:
let
  bugfixedFirefox = pkgs.firefox-esr-unwrapped // { requireSigning = false; allowAddonSideload = true; };
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
            # "browser.uiCustomization.state" = "{\"placements\":{\"widget-overflow-fixed-list\":[],\"unified-extensions-area\":[\"_testpilot-containers-browser-action\",\"jid1-bofifl9vbdl2zq_jetpack-browser-action\",\"_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action\"],\"nav-bar\":[\"back-button\",\"forward-button\",\"stop-reload-button\",\"customizableui-special-spring1\",\"urlbar-container\",\"customizableui-special-spring2\",\"save-to-pocket-button\",\"downloads-button\",\"fxa-toolbar-menu-button\",\"ublock0_raymondhill_net-browser-action\",\"sponsorblocker_ajay_app-browser-action\",\"unified-extensions-button\",\"_c607c8df-14a7-4f28-894f-29e8722976af_-browser-action\"],\"toolbar-menubar\":[\"menubar-items\"],\"TabsToolbar\":[\"tabbrowser-tabs\",\"new-tab-button\",\"alltabs-button\"],\"PersonalToolbar\":[\"personal-bookmarks\"]},\"seen\":[\"_testpilot-containers-browser-action\",\"jid1-bofifl9vbdl2zq_jetpack-browser-action\",\"ublock0_raymondhill_net-browser-action\",\"_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action\",\"_c607c8df-14a7-4f28-894f-29e8722976af_-browser-action\",\"sponsorblocker_ajay_app-browser-action\",\"developer-button\"],\"dirtyAreaCache\":[\"unified-extensions-area\",\"nav-bar\",\"TabsToolbar\"],\"currentVersion\":20,\"newElementCount\":3}";
            "browser.uiCustomization.state" = ''
              {"placements":{"widget-overflow-fixed-list":[],"unified-extensions-area":["_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action","ublock0_raymondhill_net-browser-action","_4b547b2c-e114-4344-9b70-09b2fe0785f3_-browser-action","addon_darkreader_org-browser-action","_7fee47a1-8299-4576-90bf-5fd88d756926_-browser-action","_testpilot-containers-browser-action","_ed630365-1261-4ba9-a676-99963d2b4f54_-browser-action","user-agent-switcher_ninetailed_ninja-browser-action","jid1-bofifl9vbdl2zq_jetpack-browser-action","_c5b32a48-5514-4a46-81f2-075ebf3cbc29_-browser-action","_18dd1c24-e354-4af1-9848-892a2d4c8c63_-browser-action","jid1-kkzogwgsw3ao4q_jetpack-browser-action","simple-translate_sienori-browser-action","sponsorblocker_ajay_app-browser-action","_cc2cbbd2-14d9-4260-b78d-ed166ca4e6cc_-browser-action","_a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7_-browser-action","nixos_bitwarden-browser-action","nixos_decentraleyes-browser-action","nixos_i-still-dont-care-about-cookies-browser-action","nixos_multi-account-containers-browser-action","nixos_reddit-comments-for-youtube-browser-action","nixos_tampermonkey-browser-action"],"nav-bar":["back-button","forward-button","stop-reload-button","urlbar-container","save-to-pocket-button","downloads-button","checkerplusforgmail_jasonsavard_com-browser-action","_9350bc42-47fb-4598-ae0f-825e3dd9ceba_-browser-action","_d7742d87-e61d-4b78-b8a1-b469842139fa_-browser-action","treestyletab_piro_sakura_ne_jp-browser-action","_3c078156-979c-498b-8990-85f7987dd929_-browser-action","_7a7a4a92-a2a0-41d1-9fd7-1e92480d612d_-browser-action","firefox_tampermonkey_net-browser-action","notification-bug-1658462_sferro_dev-browser-action","unified-extensions-button","reset-pbm-toolbar-button","_c607c8df-14a7-4f28-894f-29e8722976af_-browser-action","nixos_temporary-containers-browser-action","nixos_ublock-origin-browser-action","nixos_sponsorblock-browser-action"],"toolbar-menubar":["menubar-items"],"TabsToolbar":["tabbrowser-tabs","new-tab-button","alltabs-button"],"PersonalToolbar":["personal-bookmarks","bookmarks-menu-button"]},"seen":["developer-button","save-to-pocket-button","_18dd1c24-e354-4af1-9848-892a2d4c8c63_-browser-action","_testpilot-containers-browser-action","ublock0_raymondhill_net-browser-action","_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action","jid1-kkzogwgsw3ao4q_jetpack-browser-action","checkerplusforgmail_jasonsavard_com-browser-action","_4b547b2c-e114-4344-9b70-09b2fe0785f3_-browser-action","simple-translate_sienori-browser-action","jid1-bofifl9vbdl2zq_jetpack-browser-action","_ed630365-1261-4ba9-a676-99963d2b4f54_-browser-action","_cc2cbbd2-14d9-4260-b78d-ed166ca4e6cc_-browser-action","sponsorblocker_ajay_app-browser-action","user-agent-switcher_ninetailed_ninja-browser-action","_c607c8df-14a7-4f28-894f-29e8722976af_-browser-action","addon_darkreader_org-browser-action","_d7742d87-e61d-4b78-b8a1-b469842139fa_-browser-action","_9350bc42-47fb-4598-ae0f-825e3dd9ceba_-browser-action","_7fee47a1-8299-4576-90bf-5fd88d756926_-browser-action","chrome-gnome-shell_gnome_org-browser-action","treestyletab_piro_sakura_ne_jp-browser-action","_3c078156-979c-498b-8990-85f7987dd929_-browser-action","_7a7a4a92-a2a0-41d1-9fd7-1e92480d612d_-browser-action","firefox_tampermonkey_net-browser-action","_c5b32a48-5514-4a46-81f2-075ebf3cbc29_-browser-action","notification-bug-1658462_sferro_dev-browser-action","_a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7_-browser-action","nixos_bitwarden-browser-action","nixos_decentraleyes-browser-action","nixos_i-still-dont-care-about-cookies-browser-action","nixos_multi-account-containers-browser-action","nixos_reddit-comments-for-youtube-browser-action","nixos_tampermonkey-browser-action","nixos_temporary-containers-browser-action","nixos_ublock-origin-browser-action","nixos_sponsorblock-browser-action"],"dirtyAreaCache":["nav-bar","PersonalToolbar","toolbar-menubar","TabsToolbar","widget-overflow-fixed-list","unified-extensions-area"],"currentVersion":19,"newElementCount":28}
            '';
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

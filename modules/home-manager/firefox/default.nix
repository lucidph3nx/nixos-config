{ config, pkgs, lib, ... }:

let
  homeDir = config.home.homeDirectory;
in
{
  imports = [
    ./homePage.nix
    ./tridactyl.nix
    ./tridactylStyle.nix
    ./userChrome.nix
    ./userContent.nix
  ];
  options = {
    homeManagerModules.firefox.enable =
      lib.mkEnableOption "enables firefox";
  };
  config = lib.mkIf config.homeManagerModules.firefox.enable {
    programs.firefox = {
      enable = true;
      nativeMessagingHosts = [
        pkgs.tridactyl-native
      ];
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
            "browser.uiCustomization.state" = "{\"placements\":{\"widget-overflow-fixed-list\":[],\"unified-extensions-area\":[\"nixos_bitwarden-browser-action\",\"nixos_decentraleyes-browser-action\",\"nixos_i-still-dont-care-about-cookies-browser-action\",\"nixos_multi-account-containers-browser-action\",\"nixos_reddit-comments-for-youtube-browser-action\",\"nixos_tampermonkey-browser-action\"],\"nav-bar\":[\"back-button\",\"forward-button\",\"stop-reload-button\",\"customizableui-special-spring1\",\"urlbar-container\",\"customizableui-special-spring2\",\"save-to-pocket-button\",\"downloads-button\",\"fxa-toolbar-menu-button\",\"nixos_ublock-origin-browser-action\",\"nixos_sponsorblock-browser-action\",\"unified-extensions-button\",\"nixos_temporary-containers-browser-action\"],\"toolbar-menubar\":[\"menubar-items\"],\"TabsToolbar\":[\"firefox-view-button\",\"tabbrowser-tabs\",\"new-tab-button\",\"alltabs-button\"],\"PersonalToolbar\":[\"personal-bookmarks\"]},\"seen\":[\"nixos_bitwarden-browser-action\",\"nixos_decentraleyes-browser-action\",\"nixos_i-still-dont-care-about-cookies-browser-action\",\"nixos_multi-account-containers-browser-action\",\"nixos_reddit-comments-for-youtube-browser-action\",\"nixos_tampermonkey-browser-action\",\"nixos_temporary-containers-browser-action\",\"nixos_ublock-origin-browser-action\",\"nixos_sponsorblock-browser-action\",\"developer-button\"],\"dirtyAreaCache\":[\"unified-extensions-area\",\"nav-bar\",\"TabsToolbar\"],\"currentVersion\":19,\"newElementCount\":3}";
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
    xdg.mimeApps.defaultApplications = {
      "text/html" = [ "firefox.desktop" ];
      "text/xml" = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
    };
    # persist firefox directory
    home.persistence = {
      "/persist/home".directories = [ ".mozilla/firefox" ];
    };
  };
}

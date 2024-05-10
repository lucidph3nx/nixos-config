{ config, pkgs, lib, ... }:

with config.theme;
let
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
    home.file.".config/tridactyl/tridactylrc".text = 
    /*
    tridactyl 
    */
    ''
      " Unbind
      unbind --mode=normal t
      " Binds
      bind o fillcmdline open
      bind O fillcmdline tabopen
      bind cl tabclosealltoright
      bind ch tabclosealltoleft
      bind tg tabdetach
      bind / fillcmdline find
      bind ? fillcmdline find -?
      bind n findnext 1
      bind N findnext -1
      " this allows clearing of search highlights on escape
      bind <Escape> composite mode normal | nohlsearch
      " Quickmarks
      quickmark c calendar.google.com
      quickmark g github.com
      quickmark i instagram.com
      quickmark j https://jardengroup.atlassian.net/jira/software/c/projects/PLAT/boards/191
      quickmark m messenger.com
      quickmark r reddit.com
      quickmark w https://www.metservice.com/towns-cities/locations/wellington
      quickmark y youtube.com
      " Editor
      set editorcmd kitty --class qute-editor -e nvim
      " Theme
      colors everforest
      " Disable
      blacklistadd https://monkeytype.com/
      " Search Urls
      setnull searchurls.github
      set searchurls.hm https://home-manager-options.extranix.com/?query=
      set searchurls.nixpkgs https://search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=
      set searchurls.nix https://search.nixos.org/options?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=
    '';
    home.".config/tridactyl/home.html".text = 
    /*
    html
    */
    ''
    <html>
      <head>
        <link rel="stylesheet" href="chrome://activity-stream/content/css/activity-stream.css">
        <!-- <style> -->
          <!-- --newtab-textbox-focus-color: ${bg0} !important; -->
          <!-- </style> -->
      </head>
      <body style="background-color: ${bg0}; ">
        <div class="outer-wrapper ds-outer-wrapper-breakpoint-override only-search visible-logo">
          <main>
            <div class="non-collapsible-section">
              <div class="search-wrapper">
                <div class="logo-and-wordmark" style="width:100%;">
                  <div class="logo"></div>
                  <div class="wordmark" style="fill: ${foreground} !important;"></div>
                </div>
                <div class="search-inner-wrapper" padding-inline-start>
                  <form style="display: block; font-family='JetBrainsMonoNerdFont',monospace; width:100%;">
                    <input
                      style="background-color: ${bg3}; color: ${foreground}; border-radius: 0px !important; --newtab-primary-action-background: ${green}; padding-inline-start:10px; height: 50px;"
                      type="text" size="50" name="q" placeholder="Search the web" id="search-field">
                    <input type="submit" style="display: none;" formaction="https://google.com/search?hl=en&amp;q={}"
                      formmethod="get">
                  </form>
                </div>
              </div>
            </div>
          </main>
        </div>
      </body>
      </html>
    '';


    home.file = {
      ".config/tridactyl/themes/everforest.css".source = ./files/tridactyl-style;
      ".mozilla/firefox/main/chrome/userChrome.css".source = ./files/firefox-userChrome;
      ".mozilla/firefox/main/chrome/userContent.css".source = ./files/firefox-userContent;
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

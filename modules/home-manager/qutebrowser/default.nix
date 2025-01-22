{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./colours.nix
    ./greasemonkey.nix
    ./keybindings.nix
  ];
  options = {
    homeManagerModules.qutebrowser.enable =
      lib.mkEnableOption "enables qutebrowser"
      // {
        default = true;
      };
  };
  config = lib.mkIf config.homeManagerModules.qutebrowser.enable (let
    qutebrowser-setup = pkgs.writeShellScript "qutebrowser-setup" (
      builtins.concatStringsSep "\n" (builtins.map (n: "${config.programs.qutebrowser.package}/share/qutebrowser/scripts/dictcli.py install ${n}") config.programs.qutebrowser.settings.spellcheck.languages)
    );
    bitwarden-userscript =
      pkgs.writers.writePython3Bin "bitwarden" {
        flakeIgnore = ["E126" "E302" "E501" "E402" "E265" "W503"];
        libraries = with pkgs.python312Packages; [tldextract pyperclip];
      }
      (builtins.readFile ./userscripts/bitwarden);
  in {
    # systemd unit to fetch qutebrowser dicts
    systemd.user.services.qutebrowser-setup = {
      Unit = {
        Description = "Fetch qutebrowser dicts for my languages";
        After = ["network-online.target"];
        Wants = ["network-online.target"];
      };
      Service = {
        Type = "oneshot";
        ExecStart = qutebrowser-setup;
      };
      Install = {
        WantedBy = ["default.target"];
      };
    };
    programs.qutebrowser = {
      enable = true;
      settings = {
        url = {
          start_pages = [
            "qute://start"
          ];
          default_page = "qute://start";
          open_base_url = true; # open base url when a search engine is used without a query
        };
        downloads = {
          location = {
            directory = "~/downloads";
            prompt = false;
          };
        };
        content = {
          # disable autoplay globally
          autoplay = false;
          geolocation = false;
          # turn off notifications
          notifications = {
            enabled = false;
          };
          javascript = {
            clipboard = "access";
          };
          tls = {
            certificate_errors = "ask-block-thirdparty";
          };
          # don't register handlers for things like mail and calendar
          register_protocol_handler = false;
        };
        confirm_quit = [
          "downloads"
        ];
        completion.open_categories = [
          "searchengines"
          "quickmarks"
          "bookmarks"
          "history"
        ];
        spellcheck = {
          languages = [
            "en-AU"
          ];
        };
        editor.command = [
          "${pkgs.kitty}/bin/kitty"
          "--class"
          "qute-editor"
          "-e"
          "nvim"
          "{}"
        ];
        fonts = {
          default_family = "JetBrainsMono Nerd Font";
          default_size = "10pt";
        };
        # false beacuse it causes a weird olour shift
        # https://github.com/qutebrowser/qutebrowser/issues/5528
        window.hide_decoration = false;
        tabs = {
          position = "top";
          # only show if there are multiple tabs
          show = "multiple";
          favicons = {
            scale = 1;
          };
          # close window if last tab is closed
          last_close = "close";
        };
        hints.radius = 0; # no rounded corners on hints
        fileselect = {
          handler = "external";
          single_file.command = [
            "${pkgs.kitty}/bin/kitty"
            "--class"
            "qute-filepicker"
            "-e"
            "${pkgs.lf}/bin/lf"
            "-selection-path"
            "{}"
          ];
          multiple_files.command = [
            "${pkgs.kitty}/bin/kitty"
            "--class"
            "qute-filepicker"
            "-e"
            "${pkgs.lf}/bin/lf"
            "-selection-path"
            "{}"
          ];
        };
      };
      extraConfig =
        /*
        python
        */
        ''
          # enable geolocation on some sites
          config.set('content.geolocation',True, 'https://www.bunnings.co.nz')
          config.set('content.geolocation',True, 'https://www.metlink.org.nz')
          config.set('content.geolocation',True, 'https://www.newworld.co.nz')
          config.set('content.geolocation',True, 'https://www.pbtech.co.nz')
          # tab padding
          c.tabs.padding = {
            'bottom': 5,
            'left': 5,
            'top': 5,
            'right': 5,
          }
        '';
      quickmarks = {
        "fm" = "messenger.com";
        "gc" = "calendar.google.com";
        "gh" = "github.com";
        "gm" = "maps.google.com";
        "gp" = "photos.google.com";
        "ww" = "https://www.metservice.com/towns-cities/locations/wellington";
        "yt" = "youtube.com";
      };
      searchEngines = {
        "DEFAULT" = "https://search.tinfoilforest.nz/search?q={}";
        "gg" = "https://google.com/search?hl=en&q={}";
        "gh" = "https://github.com/search?q={}";
        "ghnx" = "https://github.com/search?q={}+language%3ANix&type=code&l=Nix";
        "hm" = "https://home-manager-options.extranix.com/?query={}";
        "nixopt" = "https://search.nixos.org/options?channel=unstable&from=0&size=50&sort=relevance&type=packages&query={}";
        "nixpkgs" = "https://search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&type=packages&query={}";
        "nw" = "https://www.newworld.co.nz/shop/search?q={}";
        "reo" = "https://maoridictionary.co.nz/search?idiom=&phrase=&proverb=&loan=&histLoanWords=&keywords={}";
        "wk" = "https://en.wikipedia.org/w/index.php?search={}&title=Special%3ASearch&ns0=1";
        "yt" = "https://www.youtube.com/results?search_query={}";
      };
    };
    xdg.configFile."qutebrowser/bookmarks/urls" = {
      text = ''
        https://bank.westpac.co.nz/one/app.html#login bank
        https://kubesearch.dev/ kubesearch
        https://mail.google.com/mail/u/0/ gmail0
        https://mail.google.com/mail/u/1/ gmail1
        https://photos.google.com/ photos
        https://music.youtube.com/ ytm
        https://www.youtube.com/ youtube
        https://www.notion.so/ph3nx notion
        https://www.notion.so/ph3nx/1db29fec27504e22b58755d4df3881c1?v=1fcaf59aab3f4e3fb5f2822ff0038b6d meal-recipes
        https://www.notion.so/ph3nx/Shopping-List-92d98ac3dc86460285a399c0b1176fc5 shopping-list
        https://www.nzpost.co.nz/tools/tracking nzpost tracking
        https://www.openstreetmap.org/#map=13/-41.2751/174.8099 osm
        https://github.com/lucidph3nx/nixos-config nixos-config
        https://github.com/lucidph3nx/home-ops home-ops
        https://chatgpt.com/ chatgpt
      '';
    };
    xdg.dataFile."qutebrowser/userscripts/bitwarden" = {
      source = "${bitwarden-userscript}/bin/bitwarden";
    };
    xdg.dataFile."qutebrowser/userscripts/open-firefox" = {
      source = ./userscripts/open-firefox;
    };
    xdg.dataFile."qutebrowser/userscripts/open-bitwarden" = {
      source = ./userscripts/open-bitwarden;
    };
    xdg.dataFile."qutebrowser/userscripts/ytm-download" = {
      source = ./userscripts/ytm-download;
    };
    home.persistence."/persist/home/ben" = {
      directories = [
        ".local/share/qutebrowser"
      ];
    };
    xdg.mimeApps.defaultApplications = lib.mkIf (config.homeManagerModules.defaultBrowser == "qutebrowser") {
      "text/html" = ["org.qutebrowser.qutebrowser.desktop"];
      "text/xml" = ["org.qutebrowser.qutebrowser.desktop"];
      "x-scheme-handler/http" = ["org.qutebrowser.qutebrowser.desktop"];
      "x-scheme-handler/https" = ["org.qutebrowser.qutebrowser.desktop"];
    };
  });
}

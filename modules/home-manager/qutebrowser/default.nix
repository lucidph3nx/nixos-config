{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  options = {
    homeManagerModules.qutebrowser.enable =
      lib.mkEnableOption "enables qutebrowser"
      // {
        default = true;
      };
    # currently doesnt do anything WIP
  };
  config = let
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
        };
        downloads.location.directory = "~/downloads";
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
          default_family = "JetBrains Mono";
          default_size = "10pt";
        };
        window.hide_decoration = true;
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
        colors = with config.theme; {
          webpage = {
            preferred_color_scheme = "${type}";
          };
          keyhint = {
            fg = "${foreground}";
            suffix.fg = "${red}";
            bg = "${bg0}";
          };
          messages = {
            error = {
              bg = "${bg_red}";
              fg = "${foreground}";
            };
            info = {
              bg = "${bg_blue}";
              fg = "${foreground}";
            };
            warning = {
              bg = "${bg_yellow}";
              fg = "${foreground}";
            };
          };
          prompts = {
            bg = "${bg0}";
            fg = "${foreground}";
          };
          completion = {
            category = {
              bg = "${bg3}";
              fg = "${foreground}";
            };
            fg = "${foreground}";
            even = {
              bg = "${bg0}";
            };
            odd = {
              bg = "${bg_dim}";
            };
            match = {
              fg = "${red}";
            };
            item = {
              selected = {
                fg = "${foreground}";
                bg = "${bg_yellow}";
                border = {
                  top = "${bg_yellow}";
                  bottom = "${bg_yellow}";
                };
              };
            };
            scrollbar = {
              bg = "${bg_dim}";
              fg = "${foreground}";
            };
          };
          hints = {
            bg = "${bg0}";
            fg = "${foreground}";
            match = {
              fg = "${red}";
            };
          };
          statusbar = {
            normal = {
              fg = "${foreground}";
              bg = "${bg3}";
            };
            insert = {
              fg = "${bg0}";
              bg = "${statusline1}";
            };
            caret = {
              fg = "${bg0}";
              bg = "${purple}";
            };
            command = {
              fg = "${foreground}";
              bg = "${bg0}";
            };
            passthrough = {
              fg = "${bg0}";
              bg = "${blue}";
            };
            url = {
              error = {
                fg = "${orange}";
              };
              fg = "${foreground}";
              hover = {
                fg = "${blue}";
              };
              success = {
                http = {
                  fg = "${green}";
                };
                https = {
                  fg = "${green}";
                };
              };
            };
          };
          tabs = {
            bar = {
              bg = "${bg_dim}";
            };
            even = {
              bg = "${bg0}";
              fg = "${foreground}";
            };
            odd = {
              bg = "${bg0}";
              fg = "${foreground}";
            };
            selected = {
              even = {
                bg = "${bg2}";
                fg = "${foreground}";
              };
              odd = {
                bg = "${bg2}";
                fg = "${foreground}";
              };
            };
            indicator = {
              start = "${blue}";
              stop = "${green}";
              error = "${red}";
            };
          };
        };
        hints.border = "0px solid black";
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
      # keybindings
      # I did used to use a combination of config.bind and c.bindings
      # but my 'ch' with no leader did not work in config.bind
      # and having a combination of binding strategies caused them to interfere
      keyBindings = {
        normal = {
          # unbind
          "<Ctrl-h>" = "nop";
          # close tabs left and right
          "ch" = "tab-only --next";
          "cl" = "tab-only --prev";
          "tg" = "tab-give";
          # bitwarden bindings
          "<Space>ll" = "spawn --userscript bitwarden --totp";
          "<Space>lu" = "spawn --userscript bitwarden --username-only";
          "<Space>lp" = "spawn --userscript bitwarden --password-only";
          "<Space>lt" = "spawn --userscript bitwarden --totp-only";
          # youtube music download
          "<Space>md" = "spawn --userscript ytm-download";
          "<Space>y" = "yank selection";
          "<Space>ff" = "spawn --userscript open-firefox";
        };
      };
      quickmarks = {
        "fm" = "messenger.com";
        "gc" = "calendar.google.com";
        "gh" = "github.com";
        "gm" = "maps.google.com";
        "ww" = "https://www.metservice.com/towns-cities/locations/wellington";
      };
      searchEngines = {
        "DEFAULT" = "https://search.tinfoilforest.nz/search?q={}";
        "gg" = "https://google.com/search?hl=en&q={}";
        "gh" = "https://github.com/search?q={}";
        "hm" = "https://home-manager-options.extranix.com/?query={}";
        "nixopt" = "https://search.nixos.org/options?channel=unstable&from=0&size=50&sort=relevance&type=packages&query={}";
        "nixpkgs" = "https://search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&type=packages&query={}";
        "nw" = "https://www.newworld.co.nz/shop/search?q={}";
        "reo" = "https://maoridictionary.co.nz/search?idiom=&phrase=&proverb=&loan=&histLoanWords=&keywords={}";
        "yt" = "https://www.youtube.com/results?search_query={}";
      };
      greasemonkey = with config.theme; [
        # general theme to be applied in other sites
        (pkgs.writeText "theme.css.js"
          /*
          css
          */
          ''
            // ==UserScript==
            // @name    Userstyle (theme.css)
            // @include   *
            // ==/UserScript==
            GM_addStyle(`
            :root {
              --system-theme-fg: ${foreground};
              --system-theme-red: ${red};
              --system-theme-orange: ${orange};
              --system-theme-yellow: ${yellow};
              --system-theme-green: ${green};
              --system-theme-aqua: ${aqua};
              --system-theme-blue: ${blue};
              --system-theme-purple: ${purple};
              --system-theme-grey0: ${grey0};
              --system-theme-grey1: ${grey1};
              --system-theme-grey2: ${grey2};
              --system-theme-statusline1: ${statusline1};
              --system-theme-statusline2: ${statusline2};
              --system-theme-statusline3: ${statusline3};
              --system-theme-bg_dim: ${bg_dim};
              --system-theme-bg0: ${bg0};
              --system-theme-bg1: ${bg1};
              --system-theme-bg2: ${bg2};
              --system-theme-bg3: ${bg3};
              --system-theme-bg4: ${bg4};
              --system-theme-bg5: ${bg5};
              --system-theme-bg_visual: ${bg_visual};
              --system-theme-bg_red: ${bg_red};
              --system-theme-bg_green: ${bg_green};
              --system-theme-bg_blue: ${bg_blue};
              --system-theme-bg_yellow: ${bg_yellow};
            }
            `)
          '')
        # modify default style of qutebrowser startpage
        (pkgs.writeText "startpage.css.js"
          /*
          css
          */
          ''
            // ==UserScript==
            // @name    Userstyle (startpage.css)
            // @include   /^qute://start/*/
            // @include    about:blank
            // ==/UserScript==
            GM_addStyle(`
            body {
              background-color: var(--system-theme-bg0);
              font-family: "JetbrainsMonoNerdFont", monospace;
            }
            .header {
              margin-top: 220px;
            }
            input {
              background-color: var(--system-theme-bg3);
              color: var(--system-theme-fg);
              border-radius: 0px !important;
              font-family: "JetbrainsMonoNerdFont", monospace;
            }
            ::placeholder {
              color: var(--system-theme-fg) !important;
            }
            .bookmarks {
              display: none;
            }
            `)
          '')
      ];
    };
    xdg.dataFile."qutebrowser/userscripts/bitwarden" = {
      source = "${bitwarden-userscript}/bin/bitwarden";
    };
    home.persistence."/persist/home/ben" = {
      directories = [
        ".local/share/qutebrowser"
      ];
    };
  };
}

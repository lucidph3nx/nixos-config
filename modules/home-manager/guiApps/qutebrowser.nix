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
  config =
    let
      qutebrowser-setup = pkgs.writeShellScript "qutebrowser-setup" (
        builtins.concatStringsSep "\n" (builtins.map (n: "${config.programs.qutebrowser.package}/share/qutebrowser/scripts/dictcli.py install ${n}") config.programs.qutebrowser.settings.spellcheck.languages)
      );
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
        spellcheck = {
          languages = [
            "en-AU"
          ];
        };
      };
    };
    xdg.configFile = {
      "qutebrowser/config.py" = {
        text =
          /*
          python
          */
          ''
            # pylint: disable=C0111,W0127
            c = c  # noqa: F821 pylint: disable=E0602,C0103
            config = config  # noqa: F821 pylint: disable=E0602,C0103

            # load configs done via gui
            config.load_autoconfig()

            # homepage
            c.url.start_pages = ['qute://start']
            c.url.default_page = 'qute://start'
            c.url.searchengines = {
                'DEFAULT': 'https://google.com/search?hl=en&q={}',
                'g': 'https://google.com/search?hl=en&q={}',
                'y': 'https://www.youtube.com/results?search_query={}',
                'nw': 'https://www.newworld.co.nz/shop/Search?q={}',
            }
            c.downloads.location.directory = '~/downloads'
            # content settings

            # disable autoplay globally
            c.content.autoplay = False
            # allow autoplay on some sites
            config.set('content.autoplay',True, 'https://app.pluralsight.com/*')

            # turn off geolocation
            c.content.geolocation = False
            # allow location on some sites
            config.set('content.geolocation',True, 'https://www.bunnings.co.nz')
            config.set('content.geolocation',True, 'https://www.metlink.org.nz')
            config.set('content.geolocation',True, 'https://www.newworld.co.nz')
            config.set('content.geolocation',True, 'https://www.pbtech.co.nz')

            # ms teams video, audio, screen share
            config.set('content.desktop_capture', True, 'https://teams.microsoft.com')
            config.set('content.media.audio_capture', True, 'https://teams.microsoft.com')
            config.set('content.media.video_capture', True, 'https://teams.microsoft.com')
            config.set('content.media.audio_video_capture', True, 'https://teams.microsoft.com')

            # turn off notifications
            c.content.notifications.enabled = False

            # allow clipboard access
            c.content.javascript.clipboard = 'access'

            c.content.tls.certificate_errors = 'ask-block-thirdparty'

            c.completion.open_categories = [
                'searchengines',
                'quickmarks',
                'bookmarks',
                'history'
            ]

            # theming
            c.colors.webpage.preferred_color_scheme = 'dark'
            config.source('theme.py')

            # disable window decorations (wont work unti using Qt6)
            config.set ('window.hide_decoration', True)

            # editor
            c.editor.command = ['kitty', '--class', 'qute-editor', '-e', 'nvim', '{}']

            # font
            c.fonts.default_size = '10pt'
            c.fonts.default_family = 'JetBrains Mono'
            # tabs
            c.tabs.position = 'top'
            c.tabs.show = 'multiple'  # only show tabs if multiple tabs are open
            c.tabs.favicons.scale = 1
            c.tabs.padding = {
                'bottom': 5,
                'left': 5,
                'top': 5,
                'right': 5,
            }

            # lf as browser file picker
            config.set('fileselect.handler', 'external')
            config.set(
                'fileselect.single_file.command',
                ['kitty', '--class',
                    'qute-filepicker', '-e', 'lf', '-selection-path {}'],
            )
            config.set(
                'fileselect.multiple_files.command',
                ['kitty', '--class',
                    'qute-filepicker', '-e', 'lf', '-selection-path {}'],
            )

            # keybindings
            # I did used to use a combination of config.bind and c.bindings
            # but my 'ch' with no leader did not work in config.bind
            # and having a combination of binding strategies caused them to interfere
            c.bindings.commands['normal'] = {
                # unbind
                '<Ctrl-h>': 'nop',
                # close tabs left and right
                'ch': 'tab-only --next',
                'cl': 'tab-only --prev',
                # tab give (pop out)
                'tg': 'tab-give',
                # bitwarden bindings
                '<Space>ll': 'spawn --userscript qute-bitwarden --auto-lock 604800 --totp',
                '<Space>lu': 'spawn --userscript qute-bitwarden --auto-lock 604800 --username-only',
                '<Space>lp': 'spawn --userscript qute-bitwarden --auto-lock 604800 --password-only',
                '<Space>lt': 'spawn --userscript qute-bitwarden --auto-lock 604800 --totp-only',
                # youtube music download
                '<Space>md': 'spawn --userscript ytm-download',
                '<Space>y': 'yank selection',
                # open in firefox
                '<Space>ff': 'spawn --userscript open-firefox',
            }
          '';
      };
      "qutebrowser/theme.py" = with config.theme; {
        text =
          /*
          python
          */
          ''
            from qutebrowser.config.config import ConfigContainer  # noqa: F401
            c: ConfigContainer = c  # noqa: F821 pylint: disable=E0602,C0103

            c.colors.webpage.preferred_color_scheme = "${type}"

            # c.colors.webpage.bg = "${bg0}"
            c.colors.keyhint.fg = "${foreground}"
            c.colors.keyhint.suffix.fg = "${red}"
            c.colors.keyhint.bg = "${bg0}"

            c.colors.messages.error.bg = "${bg_red}"
            c.colors.messages.error.fg = "${foreground}"
            c.colors.messages.info.bg = "${bg_blue}"
            c.colors.messages.info.fg = "${foreground}"
            c.colors.messages.warning.bg = "${bg_yellow}"
            c.colors.messages.warning.fg = "${foreground}"

            c.colors.prompts.bg = "${bg0}"
            c.colors.prompts.fg = "${foreground}"

            c.colors.completion.category.bg = "${bg3}"
            c.colors.completion.category.fg = "${foreground}"
            c.colors.completion.fg = "${foreground}"
            c.colors.completion.even.bg = "${bg0}"
            c.colors.completion.odd.bg = "${bg1}"
            c.colors.completion.match.fg = "${red}"
            c.colors.completion.item.selected.fg = "${foreground}"
            c.colors.completion.item.selected.bg = "${bg_yellow}"
            c.colors.completion.item.selected.border.top = "${bg_yellow}"
            c.colors.completion.item.selected.border.bottom = "${bg_yellow}"

            c.colors.completion.scrollbar.bg = "${bg_dim}"
            c.colors.completion.scrollbar.fg = "${foreground}"

            c.colors.hints.bg = "${bg0}"
            c.colors.hints.fg = "${foreground}"
            c.colors.hints.match.fg = "${red}"
            c.hints.border = '0px solid black'

            c.colors.statusbar.normal.fg = "${foreground}"
            c.colors.statusbar.normal.bg = "${bg3}"

            c.colors.statusbar.insert.fg = "${bg0}"
            c.colors.statusbar.insert.bg = "${statusline1}"

            c.colors.statusbar.caret.fg = "${bg0}"
            c.colors.statusbar.caret.bg = "${purple}"

            c.colors.statusbar.command.fg = "${foreground}"
            c.colors.statusbar.command.bg = "${bg0}"

            c.colors.statusbar.passthrough.fg = "${bg0}"
            c.colors.statusbar.passthrough.bg = "${blue}"

            c.colors.statusbar.url.error.fg = "${orange}"
            c.colors.statusbar.url.fg = "${foreground}"
            c.colors.statusbar.url.hover.fg = "${blue}"
            c.colors.statusbar.url.success.http.fg = "${green}"
            c.colors.statusbar.url.success.https.fg = "${green}"

            c.colors.tabs.bar.bg = "${bg_dim}"
            c.colors.tabs.even.bg = "${bg0}"
            c.colors.tabs.odd.bg = "${bg0}"
            c.colors.tabs.even.fg = "${foreground}"
            c.colors.tabs.odd.fg = "${foreground}"
            c.colors.tabs.selected.even.bg = "${bg2}"
            c.colors.tabs.selected.odd.bg = "${bg2}"
            c.colors.tabs.selected.even.fg = "${foreground}"
            c.colors.tabs.selected.odd.fg = "${foreground}"
            c.colors.tabs.indicator.start = "${blue}"
            c.colors.tabs.indicator.stop = "${green}"
            c.colors.tabs.indicator.error = "${red}"
          '';
      };
      "qutebrowser/greasemonkey/theme.css.js" = with config.theme; {
        text =
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
          '';
        };
      "qutebrowser/greasemonkey/startpage.css.js" = {
        text =
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
          '';
      };
    };
    #   home.persistence."/persist/home/ben" = {
    #     directories = [
    #       ".config/Plexamp"
    #     ];
    #   };
  };
}

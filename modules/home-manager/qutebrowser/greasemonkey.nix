{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.homeManagerModules.qutebrowser.enable {
    programs.qutebrowser.greasemonkey = with config.theme; [
      # general theme variables, to be used in other scripts
      # made available here to all sites
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
      # css styling for qutebrowser startpage
      (pkgs.writeTextFile {
        name = "startpage.css.js";
        text = builtins.readFile ./greasemonkey/startpage.css.js;
      })
      # sponsorblock for youtube videos
      (pkgs.writeTextFile {
        name = "youtube_sponsorblock.js";
        text = builtins.readFile ./greasemonkey/youtube_sponsorblock.js;
      })
      # some css styling for youtube
      (pkgs.writeTextFile {
        name = "youtube.css.js";
        text = builtins.readFile ./greasemonkey/youtube.css.js;
      })
      # adblock for reddit
      (pkgs.writeTextFile {
        name = "reddit_adblock.js";
        text = builtins.readFile ./greasemonkey/reddit_adblock.js;
      })
    ];
  };
}
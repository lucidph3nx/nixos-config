{
  config,
  pkgs,
  lib,
  ...
}:
with config.theme; {
  config = lib.mkIf config.homeManagerModules.firefox.enable {
    programs.firefox.profiles.main.userContent =
      /*
      css
      */
      ''
        /* gmail checker extension */
        @-moz-document url-prefix("moz-extension://c99d673f-ecaa-4c0f-8dc7-f7da7a89e166") {
          .share-button {
            display: none !important
          }

        }

        /* squared google calendar */
        @-moz-document url-prefix("https://calendar.google.com") {
          * {
            border-radius: 0px !important;
            text-rendering: auto !important;
          }

          *:before {
            border-radius: 0px !important;
            text-rendering: auto !important;
          }

          *:after {
            border-radius: 0px !important;
            text-rendering: auto !important;
          }

          body {
            font-family: JetBrains Mono, monospace !important;
          }
        }

        /* squared customised youtube */
        @-moz-document url-prefix("https://www.youtube.com") {
          * {
            border-radius: 0px !important;
          }

          body {
            font-family: JetBrains Mono, monospace !important;
          }
        }

        /* squared customised github */
        @-moz-document url-prefix("https://github.com") {
          * {
            border-radius: 0px !important;
          }

          body {
            font-family: JetBrains Mono, monospace !important;
          }
        }

        /* squared customised jira */
        @-moz-document url-prefix("https://jardengroup.atlassian.net") {
          * {
            border-radius: 0px !important;
          }

          body {
            font-family: JetBrains Mono, monospace !important;
          }
        }

        /* squared customised proton mail */
        @-moz-document url-prefix("https://mail.proton.me") {
          * {
            border-radius: 0px !important;
          }

          body {
            font-family: JetBrains Mono, monospace !important;
          }
          :root, .ui-standard {
            --primary: ${green} !important;
            --primary-major-1: ${green} !important;
            --primary-major-2: ${green} !important;
            --primary-major-3: ${green} !important;
            --interaction-norm: ${green} !important;
            --interaction-norm-contrast: ${bg0} !important;
            --interaction-norm-major-1: ${blue} !important;
            --interaction-norm-major-2: ${blue} !important;
            --interaction-norm-major-3: ${blue} !important;
            --interaction-weak-minor-1: ${bg0} !important;
            --interaction-weak-minor-2: ${bg_dim} !important;
            --border-norm: ${bg3} !important;
            --border-weak: ${bg2} !important;
            --background-norm: ${bg0} !important;
            --background-weak: ${bg_dim} !important;
            --background-strong: ${bg1} !important;

          }
        }

        /* themed reddit */
        @-moz-document url-prefix("https://www.reddit.com") {
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

          /* Hide annoying stuff */
          .give-gold-button,
          .goldvertisement,
          .embed-comment,
          .promoted,
          .nub {
            display: none !important;
          }

          * {
            font-family: JetBrains Mono, monospace !important;
            border-radius: 0px !important;
          }

          body {
            font-size: small !important;
          }

          /* main table */
          .sitetable {
            background-color: var(--system-theme-bg_dim) !important;
          }
          /* main table links */
          .res-nightmode .link, .res-nightmode .helpcenter-form .section-content {
            background-color: var(--system-theme-bg1) !important;
            border-color: var(--system-theme-bg0) !important;
            border-style: solid !important;
            border-width: 1px !important;
            padding: 6px !important;
            margin-top: 2px !important;
            margin-bottom: 2px !important;
            box-shadow: rgba(52, 63, 68, 0.25) 0px 1px 1px 0px, rgba(52, 63, 68, 0.31) 0px 0px 1px 0px;
            display: flex !important;
          }
          .res-nightmode .tagline, .res-nightmode .entry .buttons li a, .res-nightmode .trending-subreddits strong {
            color: var(--system-theme-grey2) !important;
          }
          /* page marker */
          .res-nightmode .RESDialogSmall > h3, .res-nightmode .NERPageMarker {
            background-color: var(--system-theme-bg0) !important;
          }
          .res-nightmode .RESDialogSmall > h3, .res-nightmode .NERPageMarker > a {
            color: var(--system-theme-red) !important;
            font-weight: bold !important;
          }

          /* post rank */
          .rank {
            text-align: center !important;
            width: 40px !important;
            color: var(--system-theme-green) !important;
            margin-top: auto !important;
            margin-bottom: auto !important;
            flex-shrink: 0 !important;
          }
          /* votes */
          .midcol {
            width: 60px !important;
            flex-shrink: 0 !important;
            margin-top: auto !important;
            margin-bottom: auto !important;
          }
          .score.unvoted,
          .score.dislikes,
          .score.likes{
            color: var(--system-theme-fg) !important;
            flex-shrink: 0 !important;
          }
          .thumbnail {
            width: 70px !important;
            flex-shrink: 0 !important;
          }
          /* prevent post headings and subreddits from wrapping */
          .entry,
          .entry.unvoted,
          .entry.likes,
          .entry.dislikes {
            flex-grow: 1;
          }

          /* header area */
          #header-img {
            display: none !important;
          }
          .res-nightmode #sr-header-area, .res-nightmode #sr-more-link,
          .res-nightmode #RESShortcutsEditContainer, .res-nightmode #RESShortcutsSort, .res-nightmode #RESShortcutsRight, .res-nightmode #RESShortcutsLeft, .res-nightmode #RESShortcutsAdd {
            color: var(--system-theme-fg) !important;
            background-color: var(--system-theme-bg0) !important;
          }
          .res-nightmode #header, .res-nightmode .liveupdate-home .content {
            color: var(--system-theme-fg) !important;
            background-color: var(--system-theme-bg2) !important;
          }
          /* posts */
          .res-nightmode .entry.res-selected > .tagline, .res-nightmode .entry.res-selected .md-container > .md, .res-nightmode .entry.res-selected .md-container > .md p,
          .res-nightmode .entry.res-selected, .res-nightmode .entry.res-selected .md-container > .md {
            color: var(--system-theme-fg) !important;
          }
          .res-nightmode .res-hasNewComments .newComments {
            color: var(--system-theme-orange) !important;
          }
          /* comments */
          .usertext-body > .md {
            color: var(--system-theme-fg) !important;
          }
          .comment {
            background-color: var(--system-theme-bg1) !important;
          }
          .commentarea {
            color: var(--system-theme-fg) !important;
            background-color: var(--system-theme-bg1) !important;
          }
          .res-nightmode .comment .child:empty {
            display: none !important;
          }
          .res-nightmode .comment .child {
            background-color: var(--system-theme-bg1) !important;
            border-color: var(--system-theme-bg_dim) !important;
            border-width: 5px !important;
            border-style: solid !important;
          }
          .res-nightmode.res-commentBoxes .comment, .res-nightmode.res-commentBoxes .comment .comment .comment, .res-nightmode.res-commentBoxes .comment .comment .comment .comment .comment, .res-nightmode.res-commentBoxes .comment .comment .comment .comment .comment .comment .comment, .res-nightmode.res-commentBoxes .comment .comment .comment .comment .comment .comment .comment .comment .comment {
            color: var(--system-theme-fg) !important;
            border-radius: 0px !important;
            border-width: 3px !important;
            border-color: var(--system-theme-bg_dim) !important;
          }
          /* sidebar */
          .res-nightmode html.res-nightmode, .res-nightmode body, .res-nightmode body .content, .res-nightmode .modal-body, .res-nightmode .side, .res-nightmode .icon-menu a, .res-nightmode .side .leavemoderator, .res-nightmode .side .leavecontributor-button, .res-nightmode .side .titlebox, .res-nightmode .side .spacer .titlebox .redditname, .res-nightmode .side .titlebox .flairtoggle, .res-nightmode .side .usertext-body .md ol, .res-nightmode .side .usertext-body .md ol ol, .res-nightmode .side .usertext-body .md ol ol li, .res-nightmode .modactionlisting table *, .res-nightmode .side .recommend-box .rec-item, .res-nightmode .crosspost-preview, .res-nightmode .crosspost-thing-preview, .res-nightmode .admin_takedown, .res-nightmode .happening-now {
            color: var(--system-theme-fg) !important;
            background-color: var(--system-theme-bg_dim) !important;
          }
          .res-nightmode .sidebox .spacer, .res-nightmode .side .linkinfo,
          .res-nightmode .side .titlebox form.flairtoggle, .res-nightmode .trophy-area .content, .res-nightmode .side .md ol, .res-nightmode .side .md ul {
            color: var(--system-theme-fg) !important;
            background-color: var(--system-theme-bg1) !important;
          }
          /* Righthand side bar (pointless) */
          .listing-chooser-collapsed .listing-chooser,
          .listing-chooser li.selected,
          .listing-chooser-collapsed .grippy,
          .grippy:after {
            display: none !important;
          }
          /* Default links */
          a {
            color: var(--system-theme-blue) !important;
          }
          a:visited, a:hover {
            color: var(--system-theme-magenta) !important;
          }

          /* Inputs and buttons */
          input,
          textarea,
          .linkinfo .shortlink input,
          .new-comment .usertext-body,
          .morelink a,
          .morelink:hover a,
          .fancy-toggle-button a,
          .usertext button {
            background: var(--system-theme-bg0) !important;
            color: var(--system-theme-fg) !important;
            font-weight: normal !important;
          }

          /* Listing */
          .thing .title,
          .title:visited,
          .thing .title:hover {
            color: var(--system-theme-fg) !important;
          }

          .expando-button {
            filter: brightness(45%) contrast(180%);
            background-color: transparent !important;
          }

          .moderator,
          .green {
            color: var(--system-theme-green) !important;
          }

          .admin,
          .nsfw-stamp * {
            color: var(--system-theme-red) !important;
          }

          .buttons li {
            padding: 0 !important;
          }

          .buttons a {
            margin-right: 8px !important;
            color: var(--system-theme-fg) !important;
          }
          .pagename a,
          .trophy-name,
          .buttons a:hover,
          .buttons a:visited {
            color: var(--system-theme-fg) !important;
          }

          .pagename,
          .tabmenu li,
          .link .midcol,
          .buttons a,
          .subreddit {
            font-weight: normal !important;
          }

          .search-expando.collapsed:before,
          .comment-fade {
            display: none !important;
          }

          .recommended-link {
            border-color: var(--system-theme-bg0) !important;
          }

          /* Comments */
          .link .usertext .md,
          blockquote,
          pre,
          code,
          .md blockquote {
            border-left: solid 4px var(--system-theme-bg0) !important;
          }

          .md td {
            border: solid 1px var(--system-theme-bg0) !important;
          }

          hr {
            border-bottom: solid 1px var(--system-theme-bg0) !important;
          }

          .comment .author,
          .morecomments a {
            font-weight: normal !important;
          }

          /* RES */
          .guider,
          .guiders_button,
          .res-fancy-toggle-button,
          #RESConsoleContainer,
          #RESShortcutsAddFormContainer {
            background: var(--system-theme-bg0) !important;
          }

          .RESDialogSmall,
          .RESDropdownOptions,
          .RESNotification,
          #alert_message {
            background: var(--system-theme-bg0) !important;
          }

          .RES-keyNav-activeElement,
          .RES-keyNav-activeElement .md-container {
            color: var(--system-theme-fg) !important;
            background: var(--system-theme-bg0) !important;
          }

          .res-nightmode .arrow {
            filter: none !important;
          }

          .res-flairSearch.linkflairlabel>a {
            color: var(--system-theme-fg) !important;
          }

          /* Upvote/dowmnvote */
          .arrow.upmod {
            background-image: url(https://i.imgur.com/fmckYhF.png);
            /* Thick Arrow Pointing Up icon by Icons8: https://icons8.com/icon/99690/thick-arrow-pointing-up */
            background-position: -4.5px -1px;
            background-repeat: no-repeat;
            background-size: 24px 24px;
          }

          .arrow.downmod {
            background-image: url(https://i.imgur.com/aJJvTy5.png);
            /* Thick Arrow Pointing Up icon by Icons8: https://icons8.com/icon/99690/thick-arrow-pointing-up */
            background-position: -4.5px -9px;
            background-repeat: no-repeat;
            background-size: 24px 24px;
          }

          /* Score */
          .link .score.likes {
            color: var(--system-theme-red) !important;
          }

          .link .score.dislikes {
            color: var(--system-theme-magenta) !important;
          }

          .linkinfo>div:nth-child(2)>span:nth-child(1) {
            color: var(--system-theme-green) !important;
          }

          /* Subreddit header */
          .pagename a,
          .trophy-name {
            color: var(--system-theme-aqua) !important;
          }

          .tabmenu .selected a {
            color: var(--system-theme-aqua) !important;
            font-weight: bold;
          }

          /* Misc */
          a.edit-btn {
            background-color: var(--system-theme-fg) !important;
            white-space: nowrap;
            float: none;
          }

          .linkinfo .shortlink input,
          .new-comment .usertext-body,
          .morelink a,
          .morelink:hover a,
          .fancy-toggle-button a {
            background: var(--system-theme-bg0) !important;
            color: var(--system-theme-fg) !important;
            font-weight: normal !important;
          }

          .submit-text>div:nth-child(1)>a:nth-child(1),
          .submit-link>div:nth-child(1)>a:nth-child(1) {
            background: var(--system-theme-blue) !important;
            color: var(--system-theme-bg0) !important;
          }

          a.hover {
            color: var(--system-theme-aqua) !important;
          }
        }
      '';
  };
}

// ==UserScript==
// @name    Userstyle (youtube.css)
// @match        *://*.youtube.com/*
// ==/UserScript==
GM_addStyle(`
  * {
    border-radius: 0px !important;
    font-family: JetBrains Mono, monospace !important;
  }

  html[dark], [dark] {
    --yt-spec-base-background: var(--system-theme-bg_dim) !important;
    --yt-spec-raised-background: var(--system-theme-bg0) !important;
    --yt-spec-menu-background: var(--system-theme-bg0) !important;
    --yt-spec-static-overlay-text-primary: var(--system-theme-fg) !important;
    --yt-spec-static-overlay-text-secondary: var(--system-theme-grey2) !important;
    --yt-spec-text-primary: var(--system-theme-fg) !important;
    --yt-spec-text-secondary: var(--system-theme-grey2) !important;
    --ytd-searchbox-background: var(--system-theme-bg_dim) !important;
    --ytd-searchbox-legacy-border-color: var(--system-theme-bg0) !important;
  }
  .yt-spec-button-shape-next--call-to-action.yt-spec-button-shape-next--text {
    color: var(--system-theme-green) !important;
  }
  ytd-app {
    --ytd-mini-guide-width: 0px !important;
  }
  ytd-mini-guide-renderer {
    display: none !important;
  }
  #contents {
    margin-left: 0px !important;
  }
  /* hide sugested videos section */
  #secondary {
    display: none !important;
  }
  /* note, the above requires the wide=1 cookie to be set */
`)
// add cookie to force wide mode
document.cookie = 'wide=1; expires=' + new Date('3099').toUTCString() + ';domain=.youtube.com;path=/';

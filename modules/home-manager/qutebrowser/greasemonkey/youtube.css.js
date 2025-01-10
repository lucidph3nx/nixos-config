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
    --yt-spec-red-indicator: var(--system-theme-red) !important;
    --yt-spec-static-brand-red: var(--system-theme-red) !important;
  }

  /* progress bar */
  .ytp-play-progress.ytp-swatch-background-color {
    background: var(--system-theme-red) !important;
  }

  /* hide anoying branding over the top of the video bottom right */
  .annotation.annotation-type-custom.iv-branding {
    display: none !important;
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

// just for fun, use my colourscheme for the red youtube logo
const observer = new MutationObserver(() => {
  const pathElement = document.querySelector('[id^="yt-ringo2-red-svg_yt"] > g:nth-child(1) > path');
  if (pathElement) {
    pathElement.setAttribute('fill', 'var(--system-theme-primary)');
  }
});

observer.observe(document.body, { childList: true, subtree: true });

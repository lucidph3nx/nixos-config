// ==UserScript==
// @name    Userstyle (googlecalendar.css)
// @match        *://calendar.google.com/*
// ==/UserScript==
GM_addStyle(`
  * {
    border-radius: 5px !important;
    text-rendering: auto !important;
  }

  *:before {
    border-radius: 5px !important;
    text-rendering: auto !important;
  }

  *:after {
    border-radius: 5px !important;
    text-rendering: auto !important;
  }

  body {
    font-family: Noto Sans, sans-serif !important;
    --gm3-sys-color-surface-container-low: var(--system-theme-bg_dim) !important;
    --gm3-sys-color-surface: var(--system-theme-bg0) !important;
    --gm3-sys-color-surface-container-highest: var(--system-theme-bg3) !important;
    --gm3-sys-color-on-surface: var(--system-theme-fg) !important;
  }
`)

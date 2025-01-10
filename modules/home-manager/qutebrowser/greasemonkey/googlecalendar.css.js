// ==UserScript==
// @name    Userstyle (googlecalendar.css)
// @match        *://calendar.google.com/*
// ==/UserScript==
GM_addStyle(`
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
`)

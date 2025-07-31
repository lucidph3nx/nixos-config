// ==UserScript==
// @name    Restore Default Background
// @match   *://*/*
// @exclude *://*.youtube.com/*
// @exclude *://github.com/*
// @exclude *://*.reddit.com/*
// @exclude *://calendar.google.com/*
// @exclude *://search.tinfoilforest.nz/*
// @grant   GM_addStyle
// @run-at  document-idle
// ==/UserScript==

GM_addStyle(`
  body {
    background-color: revert !important;
  }
`);

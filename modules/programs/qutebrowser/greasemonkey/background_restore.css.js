// ==UserScript==
// @name    Restore White background
// @match   https://www.rnz.co.nz/*
// @grant   GM_addStyle
// ==/UserScript==

// log messages to the console
console.log("Restoring white background for sites that use body background-color.");
GM_addStyle(`
  body {
    background-color: white !important;
  }
`);

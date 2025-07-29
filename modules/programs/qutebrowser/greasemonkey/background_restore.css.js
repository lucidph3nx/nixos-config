// ==userscript==
// @name         Restore White background
// @description  Restore the white background sites that use body background-color and are broken by my global userstyle.
// @match        https://*.rnz.co.nz/*
// @grant        GM_addStyle
// ==/userscript==
GM_addStyle(`
  body {
    background-color: white !important;
  }
`);

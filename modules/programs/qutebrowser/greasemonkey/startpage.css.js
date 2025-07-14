// ==UserScript==
// @name    Userstyle (startpage.css)
// @include   /^qute://start/*/
// @include    about:blank
// ==/UserScript==
GM_addStyle(`
  body {
    background-color: var(--system-theme-bg0);
    font-family: "Quicksand", sans-serif;
    font-weight: 500;
  }
  .header {
    margin-top: 220px;
  }
  input {
    background-color: var(--system-theme-bg3);
    color: var(--system-theme-fg);
    border-radius: 5px !important;
    font-family: "Quicksand", sans-serif;
    font-weight: 500;
  }
  ::placeholder {
    color: var(--system-theme-fg) !important;
  }
  .bookmarks {
    display: none;
  }
`)

// ==UserScript==
// @name    Userstyle (searchtf.css)
// @match        *://search.tinfoilforest.nz/*
// ==/UserScript==
GM_addStyle(`
  * {
    font-family: JetBrains Mono, monospace !important;
    border-radius: 0px !important;
  }
  :root {
    --color-base-font: ${foreground} !important;
    --color-base-background: ${bg0} !important;
    --color-base-background-mobile: ${bg0} !important;
    --color-url-font: ${primary} !important;
    --color-url-visited-font: ${purple} !important;
    --color-header-background: ${bg_dim} !important;
    --color-header-border: ${bg0} !important;
    --color-footer-background: ${bg_dim} !important;
    --color-footer-border: ${bg0} !important;
    --color-sidebar-border: ${bg1} !important;
    --color-sidebar-font: ${foreground} !important;
    --color-sidebar-background: ${bg0} !important;
    --color-backtotop-font: ${foreground} !important;
    --color-backtotop-border: ${bg0} !important;
    --color-backtotop-background: ${bg_dim} !important;
    --color-btn-background: ${primary} !important;
    --color-btn-font: ${bg0} !important;
    --color-show-btn-background: ${bg1} !important;
    --color-show-btn-font: ${foreground} !important;
    --color-search-border: ${bg1} !important;
    --color-search-shadow: none !important;
    --color-search-background: ${bg0} !important;
    --color-search-font: ${foreground} !important;
    --color-search-background-hover: ${primary} !important;
    --color-error: #f55b5b;
    --color-error-background: darken(#db3434, 40%);
    --color-warning: #f1d561;
    --color-warning-background: darken(#dbba34, 40%);
    --color-success: #79f56e;
    --color-success-background: darken(#42db34, 40%);
    --color-categories-item-selected-font: ${primary} !important;
    --color-categories-item-border-selected: ${primary} !important;
    --color-autocomplete-font: ${foreground} !important;
    --color-autocomplete-border: ${bg1} !important;
    --color-autocomplete-shadow: none !important;
    --color-autocomplete-background: ${bg_dim} !important;
    --color-autocomplete-background-hover: ${bg_dim} !important;
    --color-answer-font: ${foreground} !important;
    --color-answer-background: ${bg0} !important;
    --color-result-background: ${bg0} !important;
    --color-result-border: ${bg0} !important;
    --color-result-url-font: ${foreground} !important;
    --color-result-vim-selected: #1f1f23cc;
    --color-result-vim-arrow: ${primary} !important;
    --color-result-description-highlight-font: ${foreground} !important;
    --color-result-link-font: ${primary} !important;
    --color-result-link-font-highlight: ${primary} !important;
    --color-result-link-visited-font: ${purple} !important;
    --color-result-publishdate-font: ${grey2} !important;
    --color-result-engines-font: ${grey2} !important;
    --color-result-search-url-border: ${bg1} !important;
    --color-result-search-url-font: ${foreground} !important;
    --color-result-detail-font: ${foreground} !important;
    --color-result-detail-label-font: lightgray;
    --color-result-detail-background: ${bg0}
    --color-result-detail-hr: ${bg1} !important;
    --color-result-detail-link: ${primary} !important;
    --color-result-detail-loader-border: rgba(255, 255, 255, 0.2);
    --color-result-detail-loader-borderleft: rgba(0, 0, 0, 0);
    --color-result-image-span-font: ${foreground} !important;
    --color-result-image-span-font-selected: ${bg0} !important;
    --color-result-image-background: ${bg0} !important;
    --color-settings-tr-hover: #2c2c32;
    --color-settings-engine-description-font: darken(#dcdcdc, 30%);
    --color-settings-table-group-background: #1b1b21;
    --color-toolkit-badge-font: ${foreground} !important;
    --color-toolkit-badge-background: ${bg1} !important;
    --color-toolkit-kbd-font: #000;
    --color-toolkit-kbd-background: ${foreground} !important;
    --color-toolkit-dialog-border: ${bg1} !important;
    --color-toolkit-dialog-background: ${bg_dim} !important;
    --color-toolkit-tabs-label-border: ${bg0} !important;
    --color-toolkit-tabs-section-border: ${bg1} !important;
    --color-toolkit-select-background: #313338;
    --color-toolkit-select-border: ${bg1} !important;
    --color-toolkit-select-background-hover: #373b49;
    --color-toolkit-input-text-font: ${foreground} !important;
    --color-toolkit-checkbox-onoff-off-background: #313338;
    --color-toolkit-checkbox-onoff-on-background: #313338;
    --color-toolkit-checkbox-onoff-on-mark-background: ${primary} !important;
    --color-toolkit-checkbox-onoff-on-mark-color: ${bg0} !important;
    --color-toolkit-checkbox-onoff-off-mark-background: #ddd;
    --color-toolkit-checkbox-onoff-off-mark-color: ${bg0} !important;
    --color-toolkit-checkbox-label-background: ${bg0} !important;
    --color-toolkit-checkbox-label-border: ${bg0} !important;
    --color-toolkit-checkbox-input-border: ${primary} !important;
    --color-toolkit-engine-tooltip-border: ${bg0} !important;
    --color-toolkit-engine-tooltip-background: ${bg0} !important;
    --color-toolkit-loader-border: rgba(255, 255, 255, 0.2);
    --color-toolkit-loader-borderleft: rgba(0, 0, 0, 0);
    --color-doc-code: #ddd;
    --color-doc-code-background: #4d5a6f;
  }
`)

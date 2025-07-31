// ==UserScript==
// @name    Restore Default Background
// @match   *://*/*
// @exclude *://*.youtube.com/*
// @exclude *://github.com/*
// @exclude *://*.reddit.com/*
// @exclude *://calendar.google.com/*
// @exclude *://search.tinfoilforest.nz/*
// @grant   none
// @run-at  document-idle
// ==/UserScript==

(function() {
    'use strict';

    const styleElements = document.querySelectorAll('style');
    if (styleElements.length > 0) {
        const lastStyleElement = styleElements[styleElements.length - 1];
        lastStyleElement.innerHTML = lastStyleElement.innerHTML.replace(/background-color:\s*[^;\}]+/gi, 'background-color: white');
    }
})();

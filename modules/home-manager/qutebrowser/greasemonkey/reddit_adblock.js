// ==UserScript==
// @name         remove ads from reddit
// @match        *://*.reddit.com/*
// ==/UserScript==

const removeElements = () => {
    // promoted posts has this class
    document.querySelectorAll('.promotedlink').forEach((e) => e.remove());
    // nagging about confirming email has this class
    document
        .querySelectorAll('.kEQVd8aneM1tVkcIKUyDT')
        .forEach((e) => e.remove());
};
(trySetInterval = () => {
    window.setInterval(removeElements, 1000);
})();

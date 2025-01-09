// ==UserScript==
// @name         remove ads from reddit
// @match        *://*.reddit.com/*
// ==/UserScript==

// promoted posts
document.querySelectorAll('.promotedlink').forEach((e) => e.remove());
// redesign
document.querySelectorAll('.redesign-beta-optin').forEach((e) => e.remove());
// premium ads
document.querySelectorAll('.premium-banner-outer').forEach((e) => e.remove());

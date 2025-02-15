// ==UserScript==
// @name         Reddit Delay Timer with Reflection (No Scroll)
// @namespace    http://tampermonkey.net/
// @version      1.3
// @description  Delay Reddit homepage load with a countdown timer and a reflection prompt, with scrolling disabled
// @match        *://www.reddit.com/
// @match        *://www.reddit.com/r/*
// @exclude      *://www.reddit.com/r/*/*
// @grant        none
// ==/UserScript==

(function() {
    'use strict';

    // Ensure we are only affecting the homepage or subreddit listings, not specific posts
    if (window.location.pathname.split('/').filter(Boolean).length > 2) {
        return;
    }

    // Save original document state
    const originalHTML = document.documentElement.innerHTML;

    // Replace page content with a countdown timer and reflection message
    document.documentElement.innerHTML = `
        <html>
        <head>
            <style>
                html, body {
                    overflow: hidden;
                    margin: 0;
                    padding: 0;
                    height: 100%;
                }
            </style>
        </head>
        <body style="display:flex;flex-direction:column;justify-content:center;align-items:center;height:100vh;font-size:1.5em;text-align:center;">
            <p>Are you sure you want to visit reddit.com?</p>
            <p>Is it going to add value to your life?</p>
            <p>Or are you just procrastinating?</p>
            <p><strong>Redirecting in <span id="countdown">30</span> seconds...</strong></p>
        </body>
        </html>
    `;

    let seconds = 30;
    const countdownEl = document.getElementById("countdown");

    const interval = setInterval(() => {
        seconds--;
        countdownEl.textContent = seconds;
        if (seconds <= 0) {
            clearInterval(interval);
            document.documentElement.innerHTML = originalHTML; // Restore original page
        }
    }, 1000);
})();

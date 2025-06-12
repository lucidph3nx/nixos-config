// ==userscript==
// @name    Userstyle (facebook.css)
// @match        *://*.facebook.com/*
// @grant        GM_addStyle
// @grant        GM_log
// @run-at       document-start
// ==/userscript==
(function() {
  'use strict';

  GM_addStyle(`
    * {
      border-radius: 0px !important;
    }
    body {
      font-family: "JetBrains Mono", monospace !important;
    }
  `);

  // --- Element Remover ---

  const targetText = "New notification in settings";

  /**
   * Finds and hides the text-based notification based on the structure: <span> -> <div> -> "text"
   * This version includes a safety check to ensure the div has no children.
   */
  const hideTextNotification = () => {
    const divs = document.querySelectorAll('div');
    for (const div of divs) {
      // Check that the div's text matches AND that it has no child elements.
      // This makes the selector much safer and more specific.
      if (div.textContent.trim() === targetText && div.children.length === 0) {
        const parent = div.parentElement;
        // Verify the parent is a SPAN and that it's not already hidden.
        if (parent && parent.tagName === 'SPAN' && parent.style.display !== 'none') {
          GM_log(`Found target text in a childless DIV. Hiding parent SPAN.`);
          parent.style.display = 'none';
          // Stop after finding and hiding the first match to prevent errors.
          return;
        }
      }
    }
  };

  /**
   * Finds and hides the circular masks within SVGs.
   * This makes the profile picture icons square by removing the circular mask.
   */
  const hideSvgMasks = () => {
    const masks = document.querySelectorAll('mask');
    for (const mask of masks) {
      // Check if the mask contains a <circle> element inside it
      if (mask.querySelector('circle')) {
        // If it does, just hide the mask itself, not the whole SVG.
        if (mask.style.display !== 'none') {
          GM_log(`Found and hid a circular SVG mask.`);
          mask.style.display = 'none';
        }
      }
    }
  };


  // A MutationObserver waits for changes to the page's structure.
  // This is essential because Facebook loads almost all of its content dynamically.
  const observer = new MutationObserver(() => {
    // Whenever the page changes, run our cleanup functions.
    hideTextNotification();
    hideSvgMasks();
  });

  // Start observing the entire document for additions of new elements.
  observer.observe(document.body, {
    childList: true,
    subtree: true
  });

  // Also run the functions once after a short delay on initial page load.
  setTimeout(() => {
    hideTextNotification();
    hideSvgMasks();
  }, 500);

})();

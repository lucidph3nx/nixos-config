// ==UserScript==
// @name         Custom Reddit Header
// @match        https://www.reddit.com/*
// @run-at       document-end
// ==/UserScript==

(function() {
  'use strict';

  // --- ICON DEFINITIONS ---
  const ICONS = {
    upvote: `<svg stroke="currentColor" fill="currentColor" stroke-width="0" viewBox="0 0 24 24" height="1em" width="1em" xmlns="http://www.w3.org/2000/svg"><path d="M12.781 2.375c-.381-.475-1.181-.475-1.562 0l-8 10A1.001 1.001 0 0 0 4 14h4v7a1 1 0 0 0 1 1h6a1 1 0 0 0 1-1v-7h4a1.001 1.001 0 0 0 .781-1.625l-8-10zM15 12h-1v8h-4v-8H6.081L12 4.601 17.919 12H15z"></path></svg>`,
    downvote: `<svg stroke="currentColor" fill="currentColor" stroke-width="0" viewBox="0 0 24 24" height="1em" width="1em" xmlns="http://www.w3.org/2000/svg"><path d="M20.901 10.566A1.001 1.001 0 0 0 20 10h-4V3a1 1 0 0 0-1-1H9a1 1 0 0 0-1 1v7H4a1.001 1.001 0 0 0-.781 1.625l8 10a1 1 0 0 0 1.562 0l8-10c.24-.301.286-.712.12-1.059zM12 19.399 6.081 12H10V4h4v8h3.919L12 19.399z"></path></svg>`,
    profile: `<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>`,
    mail: `<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path><polyline points="22,6 12,13 2,6"></polyline></svg>`,
    mail_new: `<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="new-mail-icon"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path><polyline points="22,6 12,13 2,6"></polyline></svg>`,
    notifications: `<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path><path d="M13.73 21a2 2 0 0 1-3.46 0"></path></svg>`,
    notifications_new: `<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="new-notification-icon"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path><path d="M13.73 21a2 2 0 0 1-3.46 0"></path></svg>`,
    chat: `<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path></svg>`,
    cog: `<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg>`,
    logout: `<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path><polyline points="16 17 21 12 16 7"></polyline><line x1="21" y1="12" x2="9" y2="12"></line></svg>`,
  };

  function createDropdown(mainLinksData, buttonText, hasChevron, secondaryLinksData = null, secondaryTitle = '') {
    const dropdown = document.createElement('div');
    dropdown.className = 'custom-dropdown';
    const button = document.createElement('button');
    button.className = 'custom-dropdown-button';
    const buttonTextSpan = document.createElement('span');
    buttonTextSpan.className = 'button-text';
    buttonTextSpan.textContent = buttonText;
    button.appendChild(buttonTextSpan);
    if (hasChevron) {
      const chevron = document.createElement('div');
      chevron.className = 'main-button-chevron';
      chevron.innerHTML = `<svg stroke="currentColor" fill="currentColor" stroke-width="0" viewBox="0 0 16 16" class="main-button-svg" height="1em" width="1em" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M1.646 4.646a.5.5 0 0 1 .708 0L8 10.293l5.646-5.647a.5.5 0 0 1 .708.708l-6 6a.5.5 0 0 1-.708 0l-6-6a.5.5 0 0 1 0-.708z"></path></svg>`;
      button.appendChild(chevron);
    }
    button.addEventListener('click', (event) => {
      event.stopPropagation();
      const parent = event.currentTarget.closest('.custom-dropdown');
      const wasOpen = parent.classList.contains('is-open');
      document.querySelectorAll('.custom-dropdown.is-open').forEach(d => { if (d !== parent) d.classList.remove('is-open'); });
      parent.classList.toggle('is-open');
    });
    dropdown.appendChild(button);
    const content = document.createElement('div');
    content.className = 'custom-dropdown-content';
    mainLinksData.forEach(linkData => {
      const a = document.createElement('a');
      a.className = 'menu-item';
      a.href = linkData.href;
      a.textContent = linkData.text;
      content.appendChild(a);
    });
    if (secondaryLinksData && secondaryLinksData.length > 0) {
      content.appendChild(document.createElement('hr'));
      const collapsibleSection = document.createElement('div');
      collapsibleSection.className = 'collapsible-section';
      const toggleWrapper = document.createElement('div');
      toggleWrapper.className = 'subheading-toggle-wrapper';
      toggleWrapper.innerHTML = `<div class="dropdown-subheading">${secondaryTitle}</div><div class="sub-toggle-chevron"><svg stroke="currentColor" fill="currentColor" stroke-width="0" viewBox="0 0 16 16" class="sub-toggle-svg" height="1em" width="1em" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M1.646 4.646a.5.5 0 0 1 .708 0L8 10.293l5.646-5.647a.5.5 0 0 1 .708.708l-6 6a.5.5 0 0 1-.708 0l-6-6a.5.5 0 0 1 0-.708z"></path></svg></div>`;
      toggleWrapper.addEventListener('click', (e) => {
        e.stopPropagation();
        e.currentTarget.closest('.collapsible-section').classList.toggle('is-expanded');
      });
      collapsibleSection.appendChild(toggleWrapper);
      const subredditList = document.createElement('div');
      subredditList.className = 'subreddit-list';
      secondaryLinksData.forEach(linkData => {
        const a = document.createElement('a');
        a.className = 'menu-item';
        a.href = linkData.href;
        a.textContent = linkData.text.replace('▸ ', '');
        subredditList.appendChild(a);
      });
      collapsibleSection.appendChild(subredditList);
      content.appendChild(collapsibleSection);
    }
    dropdown.appendChild(content);
    return dropdown;
  }

  function createUserDropdown() {
    const userArea = document.querySelector('#header-bottom-right');
    if (!userArea) return null;
    const buttonText = userArea.querySelector('.user')?.textContent.trim() || 'User';
    const hasNotification = userArea.querySelector('#mail.havemail, #notifications.active, #chat-v2.active');
    const dropdown = document.createElement('div');
    dropdown.className = 'custom-dropdown user-dropdown';
    const button = document.createElement('button');
    button.className = 'custom-dropdown-button';
    const indicatorHTML = hasNotification ? '<span class="notification-indicator"></span>' : '';
    button.innerHTML = `<span class="button-text">${buttonText}</span>${indicatorHTML}<div class="main-button-chevron"><svg stroke="currentColor" fill="currentColor" stroke-width="0" viewBox="0 0 16 16" class="main-button-svg" height="1em" width="1em" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M1.646 4.646a.5.5 0 0 1 .708 0L8 10.293l5.646-5.647a.5.5 0 0 1 .708.708l-6 6a.5.5 0 0 1-.708 0l-6-6a.5.5 0 0 1 0-.708z"></path></svg></div>`;
    button.addEventListener('click', (event) => {
      event.stopPropagation();
      dropdown.classList.toggle('is-open');
      document.querySelectorAll('.custom-dropdown.is-open').forEach(d => { if (d !== dropdown) d.classList.remove('is-open'); });
    });
    dropdown.appendChild(button);
    const content = document.createElement('div');
    content.className = 'custom-dropdown-content';
    const createMenuItem = (icon, text, href) => {
      const a = document.createElement('a');
      a.className = 'user-menu-item';
      a.href = href;
      a.innerHTML = `<span class="user-menu-icon">${icon}</span><span>${text}</span>`;
      return a;
    };
    const profileLink = userArea.querySelector('.user > a');
    if (profileLink) content.appendChild(createMenuItem(ICONS.profile, 'Profile', profileLink.href));
    content.appendChild(document.createElement('hr'));
    const mailLink = userArea.querySelector('#mail');
    if (mailLink) content.appendChild(createMenuItem(userArea.querySelector('#mail.havemail') ? ICONS.mail_new : ICONS.mail, 'Messages', mailLink.href));
    const notificationsLink = userArea.querySelector('#notifications');
    if (notificationsLink) content.appendChild(createMenuItem(userArea.querySelector('#notifications.active') ? ICONS.notifications_new : ICONS.notifications, 'Notifications', notificationsLink.href));
    const chatLink = userArea.querySelector('#chat-v2');
    if (chatLink) content.appendChild(createMenuItem(ICONS.chat, 'Chat', chatLink.href));
    content.appendChild(document.createElement('hr'));
    const prefsLink = userArea.querySelector('.pref-lang');
    if (prefsLink) content.appendChild(createMenuItem(ICONS.cog, 'Preferences', prefsLink.href));
    const logoutForm = userArea.querySelector('form.logout');
    if (logoutForm) {
      const logoutItem = createMenuItem(ICONS.logout, 'Logout', '#');
      logoutItem.addEventListener('click', (e) => { e.preventDefault(); logoutForm.submit(); });
      content.appendChild(logoutItem);
    }
    dropdown.appendChild(content);
    return dropdown;
  }

  function createAdvancedSearch() {
    const originalForm = document.querySelector('.side #search');
    if (!originalForm) return null;
    const restrictSrCheckbox = originalForm.querySelector('input[name="restrict_sr"]');
    const pathParts = window.location.pathname.split('/').filter(p => p);
    const subName = (pathParts[0] === 'r' && pathParts[1]) ? pathParts[1] : null;
    const searchWrapper = document.createElement('div');
    searchWrapper.id = 'custom-search-wrapper';
    searchWrapper.appendChild(originalForm);
    const textInput = document.createElement('input');
    textInput.type = 'text';
    textInput.name = 'q';
    textInput.autocomplete = 'off';
    textInput.placeholder = subName ? `Search in r/${subName}` : 'Search Reddit';
    const clearButton = document.createElement('button');
    clearButton.type = 'button';
    clearButton.className = 'clear-search-button';
    clearButton.innerHTML = '&times;';
    clearButton.style.display = 'none';
    originalForm.innerHTML = '';
    const searchIcon = document.createElement('div');
    searchIcon.className = 'search-icon';
    searchIcon.innerHTML = `<svg stroke="currentColor" fill="currentColor" stroke-width="0" viewBox="0 0 1024 1024" height="1em" width="1em" xmlns="http://www.w3.org/2000/svg"><path d="M909.6 854.5L649.9 594.8C690.2 542.7 712 479 712 412c0-80.2-31.3-155.4-87.9-212.1-56.6-56.7-132-87.9-212.1-87.9s-155.5 31.3-212.1 87.9C143.2 256.5 112 331.8 112 412c0 80.1 31.3 155.5 87.9 212.1C256.5 680.8 331.8 712 412 712c67 0 130.6-21.8 182.7-62l259.7 259.6a8.2 8.2 0 0 0 11.6 0l43.6-43.5a8.2 8.2 0 0 0 0-11.6zM570.4 570.4C528 612.7 471.8 636 412 636s-116-23.3-158.4-65.6C211.3 528 188 471.8 188 412s23.3-116.1 65.6-158.4C296 211.3 352.2 188 412 188s116.1 23.2 158.4 65.6S636 352.2 636 412s-23.3 116.1-65.6 158.4z"></path></svg>`;
    originalForm.appendChild(searchIcon);
    if (subName) {
      const pill = document.createElement('div');
      pill.className = 'search-pill';
      pill.innerHTML = `<span>r/${subName}</span><button class="pill-dismiss">&times;</button>`;
      originalForm.appendChild(pill);
      if (restrictSrCheckbox) restrictSrCheckbox.checked = true;
      const dismissPill = () => {
        pill.remove();
        if (restrictSrCheckbox) restrictSrCheckbox.checked = false;
        textInput.placeholder = 'Search Reddit';
        textInput.focus();
      };
      pill.querySelector('.pill-dismiss').addEventListener('click', dismissPill);
      textInput.addEventListener('keydown', (e) => {
        if (e.key === 'Backspace' && textInput.value === '' && document.querySelector('.search-pill')) {
          e.preventDefault();
          dismissPill();
        }
      });
    } else {
      if (restrictSrCheckbox) restrictSrCheckbox.checked = false;
    }
    originalForm.appendChild(textInput);
    originalForm.appendChild(clearButton);
    const nsfwCheckbox = document.querySelector('#search-nude');
    if (nsfwCheckbox) {
      const nsfwPopup = document.createElement('div');
      nsfwPopup.className = 'search-options-popup';
      nsfwPopup.appendChild(nsfwCheckbox);
      nsfwPopup.appendChild(nsfwCheckbox.nextElementSibling);
      originalForm.appendChild(nsfwPopup);
    }
    textInput.addEventListener('input', () => { clearButton.style.display = textInput.value ? 'flex' : 'none'; });
    clearButton.addEventListener('click', () => { textInput.value = ''; textInput.focus(); clearButton.style.display = 'none'; });
    return searchWrapper;
  }

  function redesignHeader() {
    if (!document.body) return;
    const customHeaderContainer = document.createElement('div');
    customHeaderContainer.id = 'custom-header-container';
    const headerLeft = document.createElement('div');
    headerLeft.className = 'header-left';
    const headerCenter = document.createElement('div');
    headerCenter.className = 'header-center';
    const headerRight = document.createElement('div');
    headerRight.className = 'header-right';
    let activeNavText;
    const pathParts = window.location.pathname.split('/').filter(p => p);
    if (pathParts[0] === 'r' && pathParts[1]) {
      activeNavText = `r/${pathParts[1]}`;
    } else {
      activeNavText = document.querySelector('#sr-header-area .sr-list > .sr-bar:first-of-type li.selected a')?.textContent || 'Home';
    }
    const navLinksData = Array.from(document.querySelectorAll('#sr-header-area .sr-list > .sr-bar:first-of-type a.choice')).map(a => ({ text: a.textContent, href: a.href }));
    const subLinksData = Array.from(document.querySelectorAll('#sr-header-area .drop-choices.srdrop > a.choice:not(.bottom-option)')).map(a => ({ text: a.textContent, href: a.href }));
    const navDropdown = createDropdown(navLinksData, activeNavText, true, subLinksData, "Subs");
    if (navDropdown) {
      navDropdown.classList.add('nav-dropdown');
      headerLeft.appendChild(navDropdown);
    }
    const advancedSearch = createAdvancedSearch();
    if (advancedSearch) headerCenter.appendChild(advancedSearch);
    const sortLinksNodes = document.querySelectorAll('#header-bottom-left .tabmenu > li > a');
    if (sortLinksNodes.length > 1) {
      const sortLinksData = Array.from(sortLinksNodes).map(a => ({ text: a.textContent, href: a.href }));
      const activeSortText = document.querySelector('#header-bottom-left .tabmenu li.selected a')?.textContent || 'Best';
      const sortDropdown = createDropdown(sortLinksData, activeSortText, true);
      if (sortDropdown) {
        sortDropdown.classList.add('sort-dropdown');
        headerRight.appendChild(sortDropdown);
      }
    }
    const userDropdown = createUserDropdown();
    if (userDropdown) headerRight.appendChild(userDropdown);
    customHeaderContainer.appendChild(headerLeft);
    customHeaderContainer.appendChild(headerCenter);
    customHeaderContainer.appendChild(headerRight);
    document.body.prepend(customHeaderContainer);

  }

  if (document.body) {
    redesignHeader();
  } else {
    window.addEventListener('DOMContentLoaded', () => {
      redesignHeader();
    });
  }

  window.addEventListener('click', () => {
    document.querySelectorAll('.custom-dropdown.is-open').forEach(dropdown => {
      dropdown.classList.remove('is-open');
    });
  });
})();

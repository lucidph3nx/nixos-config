// ==UserScript==
// @name         DeArrow
// @version      1.0.0
// @description  Replace clickbait YouTube titles with crowdsourced alternatives
// @match        *://*.youtube.com/*
// @exclude      *://*.youtube.com/subscribe_embed?*
// ==/UserScript==

(function () {
  'use strict';

  // ===== CONFIGURATION =====

  const DEARROW_CONFIG = {
    // API settings
    apiServer: 'https://sponsor.ajay.app',
    fetchTimeout: 5000,

    // Title settings
    replaceTitles: true,
    useCrowdsourcedTitles: true,
    titleFormatting: 'sentence', // 'sentence', 'title', 'original', 'lowercase'

    // Formatting options
    cleanEmojis: false, // Remove emojis from titles
    formatCustomTitles: true, // Format crowdsourced titles
    formatOriginalTitles: true, // Format original titles when no crowdsourced version

    // UI settings
    showIcon: true, // Show DeArrow icon on modified titles
    iconStyle: 'simple', // 'simple', 'badge', 'logo'
    iconEmoji: '🔍', // Emoji to use for simple icon style
    hoverShowsOriginal: true, // Hover over icon shows original title

    // Performance
    lazyLoadRelated: true, // Only process visible related videos
    cacheEnabled: true, // Cache API responses in memory

    // Debug
    debugMode: false, // Console logging for troubleshooting
  };

  // ===== TITLE CONTEXTS =====

  const TITLE_CONTEXTS = {
    watch: {
      container: '#above-the-fold, ytd-watch-metadata',
      title: '#title h1 yt-formatted-string, h1.ytd-watch-metadata yt-formatted-string',
      iconPlacement: 'append',
      priority: 1,
    },

    related: {
      container: 'ytd-compact-video-renderer, ytd-video-renderer',
      title: '#video-title',
      iconPlacement: 'inline',
      priority: 2,
    },

    grid: {
      container: 'ytd-rich-grid-media, ytd-grid-video-renderer, ytd-rich-item-renderer',
      title: '#video-title',
      iconPlacement: 'inline',
      priority: 2,
    },

    miniplayer: {
      container: '.miniplayer #info-bar',
      title: 'yt-formatted-string',
      iconPlacement: 'append',
      priority: 3,
    },
  };

  // ===== DATA CACHING =====

  const brandingCache = new Map();

  const getCachedBranding = (videoID) => {
    if (!DEARROW_CONFIG.cacheEnabled) return null;

    const cached = brandingCache.get(videoID);
    if (!cached) return null;

    // Cache expiry (5 minutes)
    const age = Date.now() - cached.timestamp;
    if (age > 300000) {
      brandingCache.delete(videoID);
      return null;
    }

    return cached.data;
  };

  const cacheBrandingData = (videoID, data) => {
    if (!DEARROW_CONFIG.cacheEnabled) return;

    brandingCache.set(videoID, {
      data: data,
      timestamp: Date.now(),
    });
  };

  // ===== UTILITY FUNCTIONS =====

  const cleanEmojis = (title) => {
    // Remove emoji characters (Unicode ranges)
    return title
      .replace(
        /[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}]/gu,
        ''
      )
      .replace(/\s+/g, ' ')
      .trim();
  };

  const toSentenceCase = (title) => {
    if (!DEARROW_CONFIG.formatOriginalTitles) return title;

    // Clean up excessive spacing
    title = title.replace(/\s+/g, ' ').trim();

    // Optional: Clean emojis
    if (DEARROW_CONFIG.cleanEmojis) {
      title = cleanEmojis(title);
    }

    // Convert to lowercase and capitalize first letter
    title = title.toLowerCase();
    return title.charAt(0).toUpperCase() + title.slice(1);
  };

  const toTitleCase = (title) => {
    const smallWords = [
      'a',
      'an',
      'and',
      'as',
      'at',
      'but',
      'by',
      'for',
      'in',
      'of',
      'on',
      'or',
      'the',
      'to',
      'with',
    ];

    const words = title.toLowerCase().split(' ');
    return words
      .map((word, index) => {
        // Always capitalize first and last word
        if (index === 0 || index === words.length - 1) {
          return word.charAt(0).toUpperCase() + word.slice(1);
        }

        // Don't capitalize small words unless at start/end
        if (smallWords.includes(word)) {
          return word;
        }

        return word.charAt(0).toUpperCase() + word.slice(1);
      })
      .join(' ');
  };

  const formatTitle = (title, isCustom) => {
    // Clean up excessive spacing
    title = title.replace(/\s+/g, ' ').trim();

    // Optional: Clean emojis
    if (DEARROW_CONFIG.cleanEmojis) {
      title = cleanEmojis(title);
    }

    // Don't format if configured to keep original
    if (DEARROW_CONFIG.titleFormatting === 'original') {
      return title;
    }

    // Apply formatting
    switch (DEARROW_CONFIG.titleFormatting) {
      case 'sentence':
        return toSentenceCase(title);
      case 'title':
        return toTitleCase(title);
      case 'lowercase':
        return title.toLowerCase();
      default:
        return title;
    }
  };

  const extractVideoID = (element, context) => {
    // Method 1: From current URL (watch page)
    if (context === 'watch') {
      const urlParams = new URLSearchParams(window.location.search);
      const videoID = urlParams.get('v');
      if (videoID) return videoID;
    }

    // Method 2: From link href
    const link = element.querySelector('a[href*="watch?v="], a[href*="/shorts/"]');
    if (link) {
      const match = link.href.match(/(?:watch\?v=|shorts\/)([a-zA-Z0-9_-]{11})/);
      if (match) return match[1];
    }

    // Method 3: From thumbnail link
    const thumbnail = element.querySelector('a#thumbnail');
    if (thumbnail) {
      const match = thumbnail.href.match(/(?:watch\?v=|shorts\/)([a-zA-Z0-9_-]{11})/);
      if (match) return match[1];
    }

    return null;
  };

  // ===== API INTEGRATION =====

  const fetchBrandingData = async (videoID) => {
    // Check cache first
    const cached = getCachedBranding(videoID);
    if (cached !== null) {
      if (DEARROW_CONFIG.debugMode) console.log('DeArrow: Using cached data for', videoID);
      return cached;
    }

    try {
      const url = `${DEARROW_CONFIG.apiServer}/api/branding?videoID=${videoID}&fetchAll=true`;

      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), DEARROW_CONFIG.fetchTimeout);

      const response = await fetch(url, {
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      if (!response.ok) {
        if (DEARROW_CONFIG.debugMode)
          console.log('DeArrow: API error', response.status, 'for', videoID);
        return null;
      }

      const data = await response.json();

      // Cache the response
      cacheBrandingData(videoID, data);

      if (DEARROW_CONFIG.debugMode) console.log('DeArrow: Fetched data for', videoID, data);

      return data;
    } catch (error) {
      if (error.name === 'AbortError') {
        if (DEARROW_CONFIG.debugMode) console.log('DeArrow: Fetch timeout for', videoID);
      } else {
        if (DEARROW_CONFIG.debugMode) console.error('DeArrow: Fetch error for', videoID, error);
      }
      return null;
    }
  };

  // ===== ICON IMPLEMENTATION =====

  const createDeArrowIcon = (originalTitle, modifiedTitle) => {
    const container = document.createElement('span');
    container.className = 'dearrow-icon-container';

    const button = document.createElement('button');
    button.className = 'dearrow-icon';
    button.textContent = DEARROW_CONFIG.iconEmoji;
    button.title = 'DeArrow: Hover to see original';
    button.dataset.originalTitle = originalTitle;
    button.dataset.dearrowTitle = modifiedTitle;

    // Prevent default button behavior
    button.addEventListener('click', (e) => {
      e.preventDefault();
      e.stopPropagation();
    });

    container.appendChild(button);
    return container;
  };

  const insertIcon = (icon, titleElement, placement) => {
    if (placement === 'append') {
      // Insert after the title element
      titleElement.parentNode.insertBefore(icon, titleElement.nextSibling);
    } else if (placement === 'inline') {
      // Insert as a sibling to the title element
      titleElement.parentNode.appendChild(icon);
    }
  };

  const setupIconHover = (iconContainer, titleElement, originalTitle, modifiedTitle) => {
    if (!DEARROW_CONFIG.hoverShowsOriginal) return;

    const button = iconContainer.querySelector('.dearrow-icon');

    button.addEventListener('mouseenter', () => {
      titleElement.textContent = originalTitle;
      titleElement.setAttribute('title', originalTitle);
    });

    button.addEventListener('mouseleave', () => {
      titleElement.textContent = modifiedTitle;
      titleElement.setAttribute('title', modifiedTitle);
    });
  };

  // ===== MAIN PROCESSING LOGIC =====

  const processVideoTitle = async (element, context) => {
    try {
      // Extract video ID
      const videoID = extractVideoID(element, context);
      if (!videoID) {
        if (DEARROW_CONFIG.debugMode) console.log('DeArrow: No video ID found');
        return;
      }

      // Find title element
      const contextConfig = TITLE_CONTEXTS[context];
      const titleElement = element.querySelector(contextConfig.title);
      if (!titleElement) {
        if (DEARROW_CONFIG.debugMode) console.log('DeArrow: No title element found');
        return;
      }

      // Store original title
      const originalTitle = titleElement.textContent.trim();
      if (!originalTitle) return;

      // Check if already processed
      if (titleElement.dataset.dearrowProcessed) return;
      titleElement.dataset.dearrowProcessed = 'true';

      // Fetch branding data
      const brandingData = await fetchBrandingData(videoID);

      // Determine new title
      let newTitle;
      let isCustom = false;

      if (
        brandingData?.titles?.[0] &&
        brandingData.titles[0].votes >= 0 &&
        DEARROW_CONFIG.useCrowdsourcedTitles
      ) {
        // Use crowdsourced title
        newTitle = brandingData.titles[0].title;
        isCustom = true;

        if (DEARROW_CONFIG.formatCustomTitles) {
          newTitle = formatTitle(newTitle, isCustom);
        }
      } else {
        // Format original title
        newTitle = formatTitle(originalTitle, false);
      }

      // Only proceed if title actually changed
      if (newTitle === originalTitle) {
        if (DEARROW_CONFIG.debugMode) console.log('DeArrow: Title unchanged for', videoID);
        return;
      }

      // Replace title
      titleElement.textContent = newTitle;
      titleElement.setAttribute('title', newTitle);

      // Add DeArrow icon with hover behavior
      if (DEARROW_CONFIG.showIcon) {
        const icon = createDeArrowIcon(originalTitle, newTitle);
        insertIcon(icon, titleElement, contextConfig.iconPlacement);
        setupIconHover(icon, titleElement, originalTitle, newTitle);
      }

      if (DEARROW_CONFIG.debugMode) {
        console.log('DeArrow: Replaced title for', videoID);
        console.log('  Original:', originalTitle);
        console.log('  New:', newTitle);
      }
    } catch (error) {
      console.error('DeArrow: Error processing title:', error);
    }
  };

  // ===== DOM OBSERVATION =====

  const setupIntersectionObserver = () => {
    if (window.dearrowIntersectionObserver) return;

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            const element = entry.target;
            const context = element.matches(TITLE_CONTEXTS.related.container) ? 'related' : 'grid';
            processVideoTitle(element, context);
            observer.unobserve(element); // Process once
          }
        });
      },
      {
        root: null,
        rootMargin: '100px', // Start processing slightly before visible
        threshold: 0.1,
      }
    );

    // Observe all video containers
    const videos = document.querySelectorAll(
      `${TITLE_CONTEXTS.related.container}, ${TITLE_CONTEXTS.grid.container}`
    );
    videos.forEach((video) => {
      if (!video.dataset.dearrowObserved) {
        video.dataset.dearrowObserved = 'true';
        observer.observe(video);
      }
    });

    window.dearrowIntersectionObserver = observer;

    // Re-observe on navigation/new content
    const mutationObserver = new MutationObserver(() => {
      const newVideos = document.querySelectorAll(
        `${TITLE_CONTEXTS.related.container}:not([data-dearrow-observed]), ${TITLE_CONTEXTS.grid.container}:not([data-dearrow-observed])`
      );
      newVideos.forEach((video) => {
        video.dataset.dearrowObserved = 'true';
        observer.observe(video);
      });
    });

    mutationObserver.observe(document.body, {
      childList: true,
      subtree: true,
    });

    window.dearrowMutationObserver = mutationObserver;
  };

  const observeYouTubePage = () => {
    const delay = 1000; // Check interval

    // Process watch page title
    const processWatchPage = () => {
      const watchContainer = document.querySelector(TITLE_CONTEXTS.watch.container);
      if (watchContainer) {
        processVideoTitle(watchContainer, 'watch');
      }
    };

    // Process related/grid videos (lazy load or immediate)
    const processRelatedVideos = () => {
      if (DEARROW_CONFIG.lazyLoadRelated) {
        // Use Intersection Observer for lazy loading
        setupIntersectionObserver();
      } else {
        // Process all immediately
        const videos = document.querySelectorAll(
          `${TITLE_CONTEXTS.related.container}, ${TITLE_CONTEXTS.grid.container}`
        );
        videos.forEach((video) => {
          const context = video.matches(TITLE_CONTEXTS.related.container) ? 'related' : 'grid';
          processVideoTitle(video, context);
        });
      }
    };

    // Main observer loop
    if (!window.dearrowIntervalID) {
      window.dearrowIntervalID = setInterval(() => {
        processWatchPage();
        processRelatedVideos();
      }, delay);
    }
  };

  // ===== CSS STYLING =====

  const injectStyles = () => {
    const style = document.createElement('style');
    style.textContent = `
      .dearrow-icon-container {
        display: inline-flex;
        align-items: center;
        margin-left: 6px;
      }

      .dearrow-icon {
        background: transparent;
        border: 1px solid var(--yt-spec-icon-inactive, #999);
        border-radius: 4px;
        padding: 2px 6px;
        cursor: pointer;
        font-size: 12px;
        line-height: 1;
        opacity: 0.6;
        transition: opacity 0.2s, background 0.2s;
        color: var(--yt-spec-text-primary, #fff);
      }

      .dearrow-icon:hover {
        opacity: 1;
        background: var(--yt-spec-badge-chip-background, rgba(255, 255, 255, 0.1));
      }

      /* Context-specific adjustments */
      #video-title .dearrow-icon-container {
        margin-left: 4px;
      }

      #video-title .dearrow-icon {
        font-size: 10px;
        padding: 1px 4px;
      }

      /* Watch page styling */
      ytd-watch-metadata .dearrow-icon-container {
        vertical-align: middle;
      }
    `;
    document.head.appendChild(style);
  };

  // ===== INITIALIZATION =====

  const init = () => {
    if (DEARROW_CONFIG.debugMode) console.log('DeArrow: Initializing...');

    // Inject CSS
    injectStyles();

    // Start observing
    observeYouTubePage();

    if (DEARROW_CONFIG.debugMode) console.log('DeArrow: Initialized successfully');
  };

  // Start when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();

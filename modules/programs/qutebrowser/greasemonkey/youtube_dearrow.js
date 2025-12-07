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
    titleFormatting: 'lowercase', // 'sentence', 'title', 'original', 'lowercase'

    // Formatting options
    cleanEmojis: false, // Remove emojis from titles
    formatCustomTitles: true, // Format crowdsourced titles
    formatOriginalTitles: true, // Format original titles when no crowdsourced version

    // UI settings
    showIcon: true, // Show DeArrow icon on modified titles
    hoverShowsOriginal: true, // Hover over icon shows original title

    // Performance
    lazyLoadRelated: true, // Only process visible related videos
    cacheEnabled: true, // Cache API responses in memory

    // Thumbnail settings
    replaceThumbnails: true, // Replace thumbnails with DeArrow thumbnails
    thumbnailCacheServer: 'https://dearrow-thumb.ajay.app', // DeArrow thumbnail cache server
    thumbnailFallback: 'randomTime', // 'randomTime', 'original', 'blank' - what to do when no crowdsourced thumbnail
    thumbnailFallbackOnError: 'original', // 'original', 'blank' - what to show if thumbnail fetch fails

    // Layout settings
    titleMaxLines: 3, // Maximum number of lines for video titles (default YouTube is 2)

    // Debug
    debugMode: true, // Console logging for troubleshooting
  };

  // ===== TITLE CONTEXTS =====

  const TITLE_CONTEXTS = {
    watch: {
      container: 'ytd-watch-metadata, ytd-watch-flexy #above-the-fold',
      title: 'h1 yt-formatted-string, h1.title yt-formatted-string, #title h1 yt-formatted-string',
      iconPlacement: 'append',
      priority: 1,
    },

    related: {
      container: 'ytd-rich-grid-media, ytd-video-renderer, ytd-movie-renderer, ytd-compact-video-renderer, ytd-compact-radio-renderer, ytd-compact-movie-renderer, ytd-playlist-video-renderer, ytd-playlist-panel-video-renderer, ytd-grid-video-renderer, ytd-grid-movie-renderer, ytd-rich-grid-slim-media, ytd-radio-renderer, ytd-reel-item-renderer, ytd-compact-playlist-renderer, ytd-playlist-renderer, ytd-grid-playlist-renderer, ytd-grid-show-renderer, ytd-structured-description-video-lockup-renderer, ytd-hero-playlist-thumbnail-renderer, yt-lockup-view-model, ytm-shorts-lockup-view-model',
      title: '#video-title, #movie-title, .yt-lockup-metadata-view-model-wiz__title .yt-core-attributed-string, .yt-lockup-metadata-view-model__title .yt-core-attributed-string, .ShortsLockupViewModelHostMetadataTitle .yt-core-attributed-string, .shortsLockupViewModelHostMetadataTitle .yt-core-attributed-string',
      iconPlacement: 'inline',
      priority: 2,
    },

    grid: {
      container: 'ytd-rich-grid-media, ytd-video-renderer, ytd-movie-renderer, ytd-compact-video-renderer, ytd-compact-radio-renderer, ytd-compact-movie-renderer, ytd-playlist-video-renderer, ytd-playlist-panel-video-renderer, ytd-grid-video-renderer, ytd-grid-movie-renderer, ytd-rich-grid-slim-media, ytd-radio-renderer, ytd-reel-item-renderer, ytd-compact-playlist-renderer, ytd-playlist-renderer, ytd-grid-playlist-renderer, ytd-grid-show-renderer, ytd-structured-description-video-lockup-renderer, ytd-hero-playlist-thumbnail-renderer, yt-lockup-view-model, ytm-shorts-lockup-view-model',
      title: '#video-title, #movie-title, .yt-lockup-metadata-view-model-wiz__title .yt-core-attributed-string, .yt-lockup-metadata-view-model__title .yt-core-attributed-string, .ShortsLockupViewModelHostMetadataTitle .yt-core-attributed-string, .shortsLockupViewModelHostMetadataTitle .yt-core-attributed-string',
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
  const durationCache = new Map(); // Cache video durations

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
      
      // Don't spam logs if we're still waiting for page to load
      return null;
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

  // Track active API requests to prevent duplicates
  const activeRequests = new Map();

  const fetchBrandingData = async (videoID) => {
    // Check cache first
    const cached = getCachedBranding(videoID);
    if (cached !== null) {
      if (DEARROW_CONFIG.debugMode) console.log('DeArrow: Using cached data for', videoID);
      return cached;
    }

    // Check if there's already an active request for this videoID
    if (activeRequests.has(videoID)) {
      if (DEARROW_CONFIG.debugMode) console.log('DeArrow: Reusing active request for', videoID);
      return activeRequests.get(videoID);
    }

    // Create new request promise
    const requestPromise = (async () => {
      try {
        const url = `${DEARROW_CONFIG.apiServer}/api/branding?videoID=${videoID}&fetchAll=true`;

        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), DEARROW_CONFIG.fetchTimeout);

        const response = await fetch(url, {
          signal: controller.signal,
        });

        clearTimeout(timeoutId);

        if (!response.ok) {
          // 404 is normal for videos without DeArrow data - don't spam logs
          if (DEARROW_CONFIG.debugMode && response.status !== 404) {
            console.log('DeArrow: API error', response.status, 'for', videoID);
          }
          // Return minimal data structure - no thumbnail replacement without videoDuration
          return {
            titles: [],
            thumbnails: [],
            randomTime: null,
            videoDuration: null,
          };
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
      } finally {
        // Clean up the active request after completion
        activeRequests.delete(videoID);
      }
    })();

    // Store the promise in active requests
    activeRequests.set(videoID, requestPromise);
    return requestPromise;
  };

  // ===== ICON IMPLEMENTATION =====

  const createDeArrowIcon = (originalTitle, modifiedTitle, context) => {
    const container = document.createElement('span');
    container.className = 'dearrow-icon-container';

    // Always show on watch page, show on hover for others
    if (context === 'watch') {
      container.classList.add('dearrow-always-visible');
    }

    // Create button with YouTube's button structure
    const button = document.createElement('button');
    button.className = 'yt-spec-button-shape-next yt-spec-button-shape-next--tonal yt-spec-button-shape-next--mono yt-spec-button-shape-next--size-s yt-spec-button-shape-next--icon-only-default';
    button.title = 'DeArrow: Hover to see original';
    button.dataset.originalTitle = originalTitle;
    button.dataset.dearrowTitle = modifiedTitle;

    // Add icon wrapper
    const iconWrapper = document.createElement('div');
    iconWrapper.className = 'yt-spec-button-shape-next__icon';
    iconWrapper.setAttribute('aria-hidden', 'true');

    // Create SVG icon
    const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
    svg.setAttribute('width', '24');
    svg.setAttribute('height', '24');
    svg.setAttribute('viewBox', '0 0 24 24');
    svg.setAttribute('fill', 'none');
    svg.style.cssText = 'display: block;';

    const circle = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
    circle.setAttribute('cx', '12');
    circle.setAttribute('cy', '12');
    circle.setAttribute('r', '8');
    circle.setAttribute('stroke', 'currentColor');
    circle.setAttribute('stroke-width', '3');
    circle.setAttribute('fill', 'none');
    circle.setAttribute('class', 'dearrow-icon-circle');

    svg.appendChild(circle);
    iconWrapper.appendChild(svg);
    button.appendChild(iconWrapper);

    // Add touch feedback (YouTube standard)
    const touchFeedback = document.createElement('yt-touch-feedback-shape');
    touchFeedback.className = 'yt-spec-touch-feedback-shape yt-spec-touch-feedback-shape--touch-response';
    touchFeedback.setAttribute('aria-hidden', 'true');

    const stroke = document.createElement('div');
    stroke.className = 'yt-spec-touch-feedback-shape__stroke';

    const fill = document.createElement('div');
    fill.className = 'yt-spec-touch-feedback-shape__fill';

    touchFeedback.appendChild(stroke);
    touchFeedback.appendChild(fill);
    button.appendChild(touchFeedback);

    // Prevent default button behavior
    button.addEventListener('click', (e) => {
      e.preventDefault();
      e.stopPropagation();
    });

    container.appendChild(button);

    if (DEARROW_CONFIG.debugMode) {
      console.log('DeArrow: Created icon container', container);
      console.log('DeArrow: Button element', button);
      console.log('DeArrow: SVG element', svg);
    }

    return container;
  };

  const insertIcon = (icon, titleElement, placement) => {
    const parent = titleElement.parentNode;

    if (placement === 'append') {
      // For watch page - set up flex layout on parent to position button properly
      if (parent) {
        parent.style.display = 'flex';
        parent.style.alignItems = 'flex-start';
        parent.style.flexWrap = 'nowrap';
        parent.style.gap = '8px';
        parent.style.width = '100%';
      }

      // Ensure title element can wrap
      titleElement.style.flex = '1 1 0';
      titleElement.style.minWidth = '0';

      // For watch page - insert after the title element
      titleElement.parentNode.insertBefore(icon, titleElement.nextSibling);
    } else if (placement === 'inline') {
      // For video cards - position button absolutely at top-right
      if (parent) {
        parent.style.position = 'relative';
        parent.style.paddingRight = '36px'; // Make room for smaller button
      }

      // Position icon absolutely and scale it down
      icon.style.position = 'absolute';
      icon.style.top = '0';
      icon.style.right = '20px'; // Move left to avoid 3-dot menu
      icon.style.transform = 'scale(0.75)';
      icon.style.transformOrigin = 'top right';

      // For video cards - append to parent (becomes sibling to title)
      titleElement.parentNode.appendChild(icon);
    }
  };

  const setupIconHover = (iconContainer, titleElement, originalTitle, modifiedTitle, thumbnailElement = null) => {
    if (!DEARROW_CONFIG.hoverShowsOriginal) return;

    const button = iconContainer.querySelector('button');

    button.addEventListener('mouseenter', () => {
      // Revert title
      titleElement.textContent = originalTitle;
      titleElement.setAttribute('title', originalTitle);

      // Revert thumbnail if available
      if (thumbnailElement && thumbnailElement.dataset.dearrowOriginalSrc) {
        thumbnailElement.dataset.dearrowCurrentSrc = thumbnailElement.src; // Store current for restore
        thumbnailElement.src = thumbnailElement.dataset.dearrowOriginalSrc;
      }
    });

    button.addEventListener('mouseleave', () => {
      // Restore modified title
      titleElement.textContent = modifiedTitle;
      titleElement.setAttribute('title', modifiedTitle);

      // Restore DeArrow thumbnail if available
      if (thumbnailElement && thumbnailElement.dataset.dearrowCurrentSrc) {
        thumbnailElement.src = thumbnailElement.dataset.dearrowCurrentSrc;
      }
    });
  };

  // ===== MAIN PROCESSING LOGIC =====

  const processVideoTitle = async (element, context) => {
    try {
      // Extract video ID
      const videoID = extractVideoID(element, context);
      if (!videoID) {
        if (DEARROW_CONFIG.debugMode)
          console.log('DeArrow: No video ID found for context:', context, element);
        return;
      }

      // Find title element
      const contextConfig = TITLE_CONTEXTS[context];
      const titleElement = element.querySelector(contextConfig.title);
      if (!titleElement) {
        if (DEARROW_CONFIG.debugMode)
          console.log(
            'DeArrow: No title element found for context:',
            context,
            'selector:',
            contextConfig.title,
            element
          );
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

      // Process thumbnail if enabled - always try, even without brandingData
      let thumbnailElement = null;
      if (DEARROW_CONFIG.replaceThumbnails) {
        thumbnailElement = await processVideoThumbnail(element, videoID, brandingData);
      }

      // Add DeArrow icon with hover behavior
      if (DEARROW_CONFIG.showIcon) {
        const icon = createDeArrowIcon(originalTitle, newTitle, context);
        insertIcon(icon, titleElement, contextConfig.iconPlacement);
        setupIconHover(icon, titleElement, originalTitle, newTitle, thumbnailElement);
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

  // ===== YOUTUBE INNERTUBE API =====

  // Alea PRNG - matches official DeArrow extension (seedrandom library)
  // This provides deterministic randomness for consistent thumbnail selection
  const alea = (seed) => {
    // Convert seed to string if needed
    seed = seed.toString();
    
    // Mash function for seed mixing
    let n = 0xefc8249d;
    const mash = (data) => {
      data = data.toString();
      for (let i = 0; i < data.length; i++) {
        n += data.charCodeAt(i);
        let h = 0.02519603282416938 * n;
        n = h >>> 0;
        h -= n;
        h *= n;
        n = h >>> 0;
        h -= n;
        n += h * 0x100000000; // 2^32
      }
      return (n >>> 0) * 2.3283064365386963e-10; // 2^-32
    };

    // Initialize state
    let s0 = mash(' ');
    let s1 = mash(' ');
    let s2 = mash(' ');
    let c = 1;

    s0 -= mash(seed);
    if (s0 < 0) s0 += 1;
    s1 -= mash(seed);
    if (s1 < 0) s1 += 1;
    s2 -= mash(seed);
    if (s2 < 0) s2 += 1;

    // Return random function
    return () => {
      const t = 2091639 * s0 + c * 2.3283064365386963e-10; // 2^-32
      s0 = s1;
      s1 = s2;
      return s2 = t - (c = t | 0);
    };
  };

  const fetchVideoMetadata = async (videoID) => {
    // Check cache first
    if (durationCache.has(videoID)) {
      return durationCache.get(videoID);
    }

    try {
      const url = 'https://www.youtube.com/youtubei/v1/player';
      const body = {
        context: {
          client: {
            clientName: 'WEB',
            clientVersion: '2.20231219.01.00',
          },
        },
        videoId: videoID,
      };

      // Add timeout to prevent hanging
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), DEARROW_CONFIG.fetchTimeout);

      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(body),
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      if (!response.ok) {
        if (DEARROW_CONFIG.debugMode) {
          console.log('DeArrow: InnerTube API error', response.status, 'for', videoID);
        }
        return null;
      }

      const data = await response.json();
      const duration = data?.videoDetails?.lengthSeconds;

      if (duration) {
        const durationNum = parseInt(duration, 10);
        durationCache.set(videoID, durationNum);
        if (DEARROW_CONFIG.debugMode) {
          console.log('DeArrow: Fetched duration from InnerTube API:', durationNum, 'seconds for', videoID);
        }
        return durationNum;
      }

      return null;
    } catch (error) {
      if (error.name === 'AbortError') {
        if (DEARROW_CONFIG.debugMode) {
          console.log('DeArrow: InnerTube API timeout for', videoID);
        }
      } else if (DEARROW_CONFIG.debugMode) {
        console.error('DeArrow: InnerTube API fetch error for', videoID, error);
      }
      return null;
    }
  };

  // ===== THUMBNAIL PROCESSING =====

  const getThumbnailUrl = (videoID, time, generateNow = false, officialTime = false) => {
    const params = new URLSearchParams({
      videoID: videoID,
      time: time.toString(),
    });

    if (generateNow) {
      params.set('generateNow', 'true');
    }

    if (officialTime) {
      params.set('officialTime', 'true');
    }

    return `${DEARROW_CONFIG.thumbnailCacheServer}/api/v1/getThumbnail?${params.toString()}`;
  };

  const findThumbnailImage = (element) => {
    // Try multiple selectors for thumbnail images
    const selectors = [
      'img#img', // Standard thumbnail
      'img.yt-core-image', // New YouTube components
      'yt-image img', // Image wrapper
      'ytd-thumbnail img', // Thumbnail component
      'a#thumbnail img', // Link wrapper
      '.yt-lockup-view-model img', // New lockup components
    ];

    for (const selector of selectors) {
      const img = element.querySelector(selector);
      if (img && img.src && !img.dataset.dearrowProcessed) {
        return img;
      }
    }

    return null;
  };

  const getVideoDuration = async (element, videoID, brandingData = null) => {
    // Method 0: PRIORITY - Use videoDuration from brandingData if available (from DeArrow API)
    // This is the FASTEST method and avoids InnerTube API calls
    if (brandingData?.videoDuration) {
      if (DEARROW_CONFIG.debugMode) {
        console.log('DeArrow: Using videoDuration from brandingData (FAST):', brandingData.videoDuration);
      }
      return brandingData.videoDuration;
    }

    // Try to extract video duration from the page
    
    // Method 1: Check for duration in video data attributes
    const videoData = element.querySelector('a[href*="watch"]');
    if (videoData) {
      const durationAttr = videoData.getAttribute('data-duration') || 
                          videoData.getAttribute('aria-label');
      if (durationAttr) {
        // Try parsing duration attribute
        const match = durationAttr.match(/(\d+):(\d+)(?::(\d+))?/);
        if (match) {
          const hours = match[3] ? parseInt(match[1], 10) : 0;
          const minutes = match[3] ? parseInt(match[2], 10) : parseInt(match[1], 10);
          const seconds = match[3] ? parseInt(match[3], 10) : parseInt(match[2], 10);
          const duration = hours * 3600 + minutes * 60 + seconds;
          
          if (duration > 0 && duration < 86400) {
            if (DEARROW_CONFIG.debugMode) {
              console.log('DeArrow: Found duration', duration, 'seconds from data attribute');
            }
            return duration;
          }
        }
      }
    }
    
    // Method 2: From time display on thumbnail - try multiple selectors
    const timeSelectors = [
      // Modern YouTube selectors
      'ytd-thumbnail-overlay-time-status-renderer span.style-scope.ytd-thumbnail-overlay-time-status-renderer',
      'ytd-thumbnail-overlay-time-status-renderer #text',
      '.ytd-thumbnail-overlay-time-status-renderer #text',
      // Older selectors
      '#overlays #text',
      '.badge-shape-wiz__text',
      'span.ytd-thumbnail-overlay-time-status-renderer',
      // Watch page
      '.ytp-time-duration',
    ];
    
    for (const selector of timeSelectors) {
      try {
        const timeDisplay = element.querySelector(selector);
        if (timeDisplay && timeDisplay.textContent) {
          const timeText = timeDisplay.textContent.trim();
          // Match formats: "10:32", "1:23:45", etc.
          const match = timeText.match(/^(\d+):(\d+)(?::(\d+))?$/);
          if (match) {
            const hours = match[3] ? parseInt(match[1], 10) : 0;
            const minutes = match[3] ? parseInt(match[2], 10) : parseInt(match[1], 10);
            const seconds = match[3] ? parseInt(match[3], 10) : parseInt(match[2], 10);
            const duration = hours * 3600 + minutes * 60 + seconds;
            
            if (duration > 0 && duration < 86400) { // Sanity check: 0 < duration < 24 hours
              if (DEARROW_CONFIG.debugMode) {
                console.log('DeArrow: Found duration', duration, 'seconds from selector', selector, 'text:', timeText);
              }
              
              return duration;
            }
          }
        }
      } catch (e) {
        // Selector might not work, continue to next
      }
    }
    
    // Method 3: From aria-label on thumbnail or metadata elements
    const labelElements = [
      element.querySelector('a#thumbnail'),
      element.querySelector('a.ytd-thumbnail'),
      element.querySelector('#meta'),
      element
    ];
    
    for (const el of labelElements) {
      if (!el) continue;
      const ariaLabel = el.getAttribute?.('aria-label');
      if (!ariaLabel) continue;
      
      // Match patterns like "10 minutes, 32 seconds" or "1 hour, 23 minutes, 45 seconds"
      const hourMatch = ariaLabel.match(/(\d+)\s+hour/i);
      const minMatch = ariaLabel.match(/(\d+)\s+minute/i);
      const secMatch = ariaLabel.match(/(\d+)\s+second/i);
      
      if (minMatch || secMatch || hourMatch) {
        const hours = hourMatch ? parseInt(hourMatch[1], 10) : 0;
        const minutes = minMatch ? parseInt(minMatch[1], 10) : 0;
        const seconds = secMatch ? parseInt(secMatch[1], 10) : 0;
        const duration = hours * 3600 + minutes * 60 + seconds;
        
        if (duration > 0) {
          if (DEARROW_CONFIG.debugMode) {
            console.log('DeArrow: Found duration', duration, 'seconds from aria-label');
          }
          
          return duration;
        }
      }
    }
    
    // Method 4: Check if we're on watch page and can access player
    if (window.location.pathname === '/watch') {
      const player = document.querySelector('video');
      if (player && player.duration && !isNaN(player.duration) && player.duration > 0) {
        if (DEARROW_CONFIG.debugMode) {
          console.log('DeArrow: Found duration', player.duration, 'seconds from video player');
        }
        return player.duration;
      }
    }
    
    // Method 5: Fallback to YouTube InnerTube API
    if (videoID) {
      const duration = await fetchVideoMetadata(videoID);
      if (duration) {
        return duration;
      }
    }
    
    if (DEARROW_CONFIG.debugMode) {
      console.log('DeArrow: Could not find duration for element', element);
    }
    
    return null;
  };

  // ===== THUMBNAIL QUEUE SYSTEM =====
  
  // Limit concurrent thumbnail generations (like official extension)
  const MAX_CONCURRENT_THUMBNAILS = 6;
  const activeThumbnailRequests = new Map();
  const thumbnailQueue = [];
  let activeThumbnailCount = 0;

  const processThumbnailQueue = () => {
    while (activeThumbnailCount < MAX_CONCURRENT_THUMBNAILS && thumbnailQueue.length > 0) {
      const { resolve, videoID, element, brandingData } = thumbnailQueue.shift();
      activeThumbnailCount++;
      
      processVideoThumbnailInternal(element, videoID, brandingData)
        .then((result) => {
          resolve(result);
        })
        .catch((error) => {
          resolve(null);
          if (DEARROW_CONFIG.debugMode) console.error('DeArrow: Thumbnail queue error:', error);
        })
        .finally(() => {
          activeThumbnailCount--;
          activeThumbnailRequests.delete(videoID);
          processThumbnailQueue(); // Process next item
        });
    }
  };

  const processVideoThumbnail = async (element, videoID, brandingData) => {
    // Check if already processing this thumbnail
    if (activeThumbnailRequests.has(videoID)) {
      if (DEARROW_CONFIG.debugMode) console.log('DeArrow: Reusing active thumbnail request for', videoID);
      return activeThumbnailRequests.get(videoID);
    }

    // Create promise for this thumbnail
    const promise = new Promise((resolve) => {
      thumbnailQueue.push({ resolve, videoID, element, brandingData });
      processThumbnailQueue();
    });

    activeThumbnailRequests.set(videoID, promise);
    return promise;
  };

  const processVideoThumbnailInternal = async (element, videoID, brandingData) => {
    try {
      // Check thumbnail fallback setting first
      if (DEARROW_CONFIG.thumbnailFallback === 'original') {
        return null; // Don't replace thumbnails unless we have crowdsourced data
      }

      // Find thumbnail image
      const thumbnailImg = findThumbnailImage(element);
      if (!thumbnailImg) {
        if (DEARROW_CONFIG.debugMode) console.log('DeArrow: No thumbnail found for', videoID);
        return null;
      }

      // Check if already processed
      if (thumbnailImg.dataset.dearrowProcessed) return thumbnailImg;
      thumbnailImg.dataset.dearrowProcessed = 'true';

      // Get thumbnail data
      let thumbnailTime = null;
      let isOfficialTime = false;

      // Priority 1: Use crowdsourced thumbnail if available
      if (brandingData?.thumbnails?.[0] && brandingData.thumbnails[0].votes >= 0) {
        thumbnailTime = brandingData.thumbnails[0].timestamp;
        isOfficialTime = true; // This is a crowdsourced timestamp
      }
      // Priority 2: Use randomTime from API if available
      else if (brandingData?.randomTime !== null && brandingData?.randomTime !== undefined) {
        // randomTime is a fraction (0.0-1.0), multiply by video duration to get timestamp
        let duration = brandingData.videoDuration;
        if (!duration) {
          // Try to get duration from page or API (passing brandingData to avoid InnerTube calls)
          duration = await getVideoDuration(element, videoID, brandingData);
        }
        
        if (duration) {
          // Apply same 90% limit as official extension if randomTime > 0.9
          let randomTime = brandingData.randomTime;
          if (randomTime > 0.9) {
            randomTime -= 0.9;
          }
          thumbnailTime = randomTime * duration;
          isOfficialTime = false;
          
          if (DEARROW_CONFIG.debugMode) {
            console.log('DeArrow: Using randomTime from API:', brandingData.randomTime, 'adjusted:', randomTime, 'duration:', duration);
          }
        } else {
          if (DEARROW_CONFIG.debugMode) {
            console.log('DeArrow: Cannot convert randomTime fraction without duration for', videoID);
          }
          return null;
        }
      }
      // Priority 3: Generate random timestamp ourselves (RandomTime fallback)
      else if (DEARROW_CONFIG.thumbnailFallback === 'randomTime') {
        // Try to get video duration - now prioritizes brandingData.videoDuration
        let duration = brandingData?.videoDuration;
        if (!duration) {
          duration = await getVideoDuration(element, videoID, brandingData);
        }
        
        if (duration) {
          // Use Alea PRNG with videoID as seed (matches official extension)
          const rng = alea(videoID);
          let randomFraction = rng();
          
          // Don't allow random times past 90% of the video (matches official extension)
          if (randomFraction > 0.9) {
            randomFraction -= 0.9;
          }
          
          thumbnailTime = randomFraction * duration;
          isOfficialTime = false;
          
          if (DEARROW_CONFIG.debugMode) {
            console.log('DeArrow: Generated deterministic random timestamp for', videoID, ':', thumbnailTime, 'of', duration, 'fraction:', randomFraction);
          }
        } else {
          if (DEARROW_CONFIG.debugMode) {
            console.log('DeArrow: Cannot generate random thumbnail without duration for', videoID);
          }
          return null;
        }
      }

      if (thumbnailTime === null) {
        if (DEARROW_CONFIG.debugMode)
          console.log('DeArrow: No thumbnail time available for', videoID);
        return null;
      }

      // Store original thumbnail
      const originalSrc = thumbnailImg.src;
      thumbnailImg.dataset.dearrowOriginalSrc = originalSrc;

      // Optimistic loading strategy (non-blocking, matches official extension behavior)
      // Try cached version first, then request generation if needed
      const cachedThumbnailUrl = getThumbnailUrl(videoID, thumbnailTime, false, isOfficialTime);
      const generateUrl = getThumbnailUrl(videoID, thumbnailTime, true, isOfficialTime);

      // Immediately set the thumbnail to the cached URL (optimistic)
      thumbnailImg.src = cachedThumbnailUrl;
      thumbnailImg.srcset = ''; // Clear srcset to prevent fallback

      // Handle load/error events to trigger generation if needed
      const onError = () => {
        // Cache miss - trigger generation by loading generateUrl
        if (DEARROW_CONFIG.debugMode) {
          console.log('DeArrow: Thumbnail not cached, requesting generation for', videoID, 'at time', thumbnailTime);
        }

        // Try generation URL
        const generateImg = new Image();
        generateImg.onload = () => {
          // Generation succeeded, update actual thumbnail
          thumbnailImg.src = generateUrl;
          if (DEARROW_CONFIG.debugMode) {
            console.log('DeArrow: Replaced thumbnail (generated) for', videoID);
          }
        };
        generateImg.onerror = () => {
          // Generation failed completely
          if (DEARROW_CONFIG.thumbnailFallbackOnError === 'blank') {
            thumbnailImg.src =
              'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="16" height="9"%3E%3Crect fill="%23282828" width="16" height="9"/%3E%3C/svg%3E';
          } else {
            // Restore original
            thumbnailImg.src = originalSrc;
          }
          if (DEARROW_CONFIG.debugMode) {
            console.log('DeArrow: Thumbnail generation failed for', videoID, 'at time', thumbnailTime);
          }
        };
        generateImg.src = generateUrl;
      };

      const onLoad = () => {
        // Cached thumbnail loaded successfully
        if (DEARROW_CONFIG.debugMode) {
          console.log('DeArrow: Replaced thumbnail (cached) for', videoID, 'at time', thumbnailTime);
        }
      };

      // Attach listeners
      thumbnailImg.addEventListener('error', onError, { once: true });
      thumbnailImg.addEventListener('load', onLoad, { once: true });

      // Return the thumbnail element for hover functionality
      return thumbnailImg;
    } catch (error) {
      if (DEARROW_CONFIG.debugMode) console.error('DeArrow: Error processing thumbnail:', error);
      return null;
    }
  };

  // ===== DOM OBSERVATION =====

  const setupIntersectionObserver = () => {
    if (window.dearrowIntersectionObserver) return;

    // Batch processing for better performance
    let batchedElements = [];
    let batchTimeout = null;

    const processBatch = () => {
      if (batchedElements.length === 0) return;
      
      if (DEARROW_CONFIG.debugMode) {
        console.log('DeArrow: Processing batch of', batchedElements.length, 'videos');
      }

      // Process all videos in parallel (like official extension)
      const promises = batchedElements.map(({ element, context }) => {
        return processVideoTitle(element, context).catch((error) => {
          if (DEARROW_CONFIG.debugMode) {
            console.error('DeArrow: Error processing video in batch:', error);
          }
        });
      });

      Promise.all(promises).then(() => {
        if (DEARROW_CONFIG.debugMode) {
          console.log('DeArrow: Batch processing complete');
        }
      });

      batchedElements = [];
      batchTimeout = null;
    };

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            const element = entry.target;
            const context = element.matches(TITLE_CONTEXTS.related.container) ? 'related' : 'grid';
            
            // Add to batch instead of processing immediately
            batchedElements.push({ element, context });
            
            // Debounce batch processing
            if (batchTimeout) clearTimeout(batchTimeout);
            batchTimeout = setTimeout(processBatch, 50); // 50ms batch window

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
    if (DEARROW_CONFIG.debugMode)
      console.log('DeArrow: Found', videos.length, 'video containers to observe');
    videos.forEach((video) => {
      if (!video.dataset.dearrowObserved) {
        video.dataset.dearrowObserved = 'true';
        observer.observe(video);
      }
    });

    window.dearrowIntersectionObserver = observer;

    // Re-observe on navigation/new content with debouncing
    let mutationTimeout = null;
    const mutationObserver = new MutationObserver(() => {
      // Debounce: wait 200ms after last mutation before processing (increased from 100ms)
      clearTimeout(mutationTimeout);
      mutationTimeout = setTimeout(() => {
        const newVideos = document.querySelectorAll(
          `${TITLE_CONTEXTS.related.container}:not([data-dearrow-observed]), ${TITLE_CONTEXTS.grid.container}:not([data-dearrow-observed])`
        );
        if (DEARROW_CONFIG.debugMode && newVideos.length > 0)
          console.log('DeArrow: Found', newVideos.length, 'new video containers via mutation');
        newVideos.forEach((video) => {
          video.dataset.dearrowObserved = 'true';
          observer.observe(video);
        });
      }, 200);
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
      // Only process if we're actually on a watch page with a video ID in URL
      if (!window.location.pathname.includes('/watch') || !window.location.search.includes('v=')) {
        return;
      }
      
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

    // Build container selectors for title max lines - combine both contexts
    const allContainers = new Set([
      ...TITLE_CONTEXTS.related.container.split(', '),
      ...TITLE_CONTEXTS.grid.container.split(', '),
    ]);

    // Build CSS rules - target both the link element and the span inside
    const titleLineClampRules = [];
    for (const container of allContainers) {
      titleLineClampRules.push(`${container} #video-title:not(.ta-title-container)`);
      titleLineClampRules.push(`${container} .yt-lockup-metadata-view-model__title:not(.ta-title-container)`);
      titleLineClampRules.push(
        `${container} .yt-lockup-metadata-view-model__title > .yt-core-attributed-string:not(.ta-title-container)`
      );
    }

    const cssContent = `
      /* Custom title element should inherit all styling from original */
      .dearrow-custom-title {
        display: inline;
      }

      /* Original title is hidden by default when DeArrow is active */
      .dearrow-original-title {
        display: none;
      }

      /* Allow titles to expand to ${DEARROW_CONFIG.titleMaxLines} lines instead of YouTube's default 2 */
      /* Must set display and box-orient for -webkit-line-clamp to work */
      ${titleLineClampRules.join(',\n      ')} {
        display: -webkit-box !important;
        -webkit-box-orient: vertical !important;
        -webkit-line-clamp: ${DEARROW_CONFIG.titleMaxLines} !important;
        max-height: unset !important;
        overflow: hidden !important;
      }

      .dearrow-icon-container {
        display: none;
        align-items: center;
        margin-left: 8px;
        flex-shrink: 0;
      }

      /* Always visible on watch page */
      .dearrow-icon-container.dearrow-always-visible {
        display: inline-flex !important;
      }

      /* Show on hover for video cards */
      *:hover > .dearrow-icon-container:not(.dearrow-always-visible) {
        display: inline-flex !important;
      }

      /* YouTube button styling fallback */
      .dearrow-icon-container .yt-spec-button-shape-next {
        position: relative;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        height: 36px;
        min-width: 36px;
        padding: 0 16px;
        border: none;
        border-radius: 18px;
        background-color: var(--yt-spec-badge-chip-background, rgba(255, 255, 255, 0.1));
        color: var(--yt-spec-text-primary, #fff);
        font-family: "Roboto", "Arial", sans-serif;
        font-size: 14px;
        font-weight: 500;
        text-transform: none;
        cursor: pointer;
        transition: background-color 0.1s ease;
        box-sizing: border-box;
      }

      .dearrow-icon-container .yt-spec-button-shape-next:hover {
        background-color: var(--yt-spec-badge-chip-background, rgba(255, 255, 255, 0.1));
      }

      .dearrow-icon-container .yt-spec-button-shape-next--size-s {
        height: 32px;
        min-width: 32px;
        padding: 0 12px;
        border-radius: 16px;
      }

      .dearrow-icon-container .yt-spec-button-shape-next--icon-only-default {
        padding: 0;
        width: 36px;
      }

      .dearrow-icon-container .yt-spec-button-shape-next--size-s.yt-spec-button-shape-next--icon-only-default {
        width: 32px;
      }

      .dearrow-icon-container .yt-spec-button-shape-next__icon {
        display: flex;
        align-items: center;
        justify-content: center;
      }

      /* Context-specific adjustments */
      #video-title .dearrow-icon-container {
        margin-left: 4px;
      }

      /* Watch page styling */
      ytd-watch-metadata .dearrow-icon-container {
        vertical-align: middle;
      }

      /* SVG icon styling */
      .dearrow-icon-circle {
        stroke: var(--system-theme-blue, #3ea6ff);
        transition: stroke 0.2s ease;
      }

      .dearrow-icon-container button:hover .dearrow-icon-circle {
        stroke: var(--system-theme-grey2, #aaa);
      }
    `;
    
    style.textContent = cssContent;
    console.log('DeArrow: Injecting CSS with', titleLineClampRules.length, 'line-clamp rules');
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

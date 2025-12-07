// ==UserScript==
// @name         DeArrow
// @version      1.0.0
// @description  Replace clickbait YouTube titles with crowdsourced alternatives
// @match        *://*.youtube.com/*
// @exclude      *://*.youtube.com/subscribe_embed?*
// @exclude      *://accounts.youtube.com/*
// ==/UserScript==

(function() {
  'use strict';

  const pageLoadId = window.performance?.timing?.navigationStart || Date.now();

  if (window.dearrowScriptLoadedId === pageLoadId) {
    return;
  }

  window.dearrowScriptLoadedId = pageLoadId;

  // ===== EARLY CSS INJECTION (ANTI-FLICKER) =====
  (function injectEarlyCSS() {
    const style = document.createElement('style');
    style.id = 'dearrow-antiflicker-css';
    style.textContent = `
      ytd-rich-grid-media ytd-thumbnail img:not(.cb-visible, .cbCustomThumbnailCanvas, .yt-spec-avatar-shape__image),
      ytd-rich-grid-media yt-thumbnail-view-model img:not(.cb-visible, .cbCustomThumbnailCanvas, .yt-spec-avatar-shape__image),
      ytd-video-renderer ytd-thumbnail img:not(.cb-visible, .cbCustomThumbnailCanvas, .yt-spec-avatar-shape__image),
      ytd-video-renderer yt-thumbnail-view-model img:not(.cb-visible, .cbCustomThumbnailCanvas, .yt-spec-avatar-shape__image),
      ytd-compact-video-renderer ytd-thumbnail img:not(.cb-visible, .cbCustomThumbnailCanvas, .yt-spec-avatar-shape__image),
      ytd-compact-video-renderer yt-thumbnail-view-model img:not(.cb-visible, .cbCustomThumbnailCanvas, .yt-spec-avatar-shape__image),
      ytd-grid-video-renderer ytd-thumbnail img:not(.cb-visible, .cbCustomThumbnailCanvas, .yt-spec-avatar-shape__image),
      ytd-grid-video-renderer yt-thumbnail-view-model img:not(.cb-visible, .cbCustomThumbnailCanvas, .yt-spec-avatar-shape__image),
      ytd-playlist-video-renderer ytd-thumbnail img:not(.cb-visible, .cbCustomThumbnailCanvas, .yt-spec-avatar-shape__image),
      ytd-playlist-panel-video-renderer ytd-thumbnail img:not(.cb-visible, .cbCustomThumbnailCanvas, .yt-spec-avatar-shape__image),
      ytd-rich-grid-slim-media ytd-thumbnail img:not(.cb-visible, .cbCustomThumbnailCanvas, .yt-spec-avatar-shape__image),
      ytd-reel-item-renderer ytd-thumbnail img:not(.cb-visible, .cbCustomThumbnailCanvas, .yt-spec-avatar-shape__image),
      yt-lockup-view-model yt-thumbnail-view-model img:not(.cb-visible, .cbCustomThumbnailCanvas, .yt-spec-avatar-shape__image),
      ytd-video-preview ytd-thumbnail img:not(.cb-visible, .cbCustomThumbnailCanvas, .yt-spec-avatar-shape__image),
      ytd-video-preview yt-thumbnail-view-model img:not(.cb-visible, .cbCustomThumbnailCanvas, .yt-spec-avatar-shape__image),
      ytd-thumbnail img:not(.cb-visible, .cbCustomThumbnailCanvas, .yt-spec-avatar-shape__image),
      yt-thumbnail-view-model img:not(.cb-visible, .cbCustomThumbnailCanvas, .yt-spec-avatar-shape__image),
      .ytp-ce-covering-image:not(.cb-visible),
      div.ytp-autonav-endscreen-upnext-thumbnail:not(.cb-visible),
      div.ytp-videowall-still-image:not(.cb-visible),
      div.ytp-modern-videowall-still-image:not(.cb-visible) {
        visibility: hidden !important;
      }
      .cb-visible {
        visibility: visible !important;
      }
    `;

    if (document.head) {
      document.head.appendChild(style);
    } else {
      document.addEventListener('DOMContentLoaded', () => {
        if (document.head && !document.getElementById('dearrow-antiflicker-css')) {
          document.head.appendChild(style);
        }
      });
    }
  })();

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
    hideWhileFetching: true, // Hide thumbnails while fetching custom ones (anti-flicker)

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

    miniplayer: {
      container: '.miniplayer #info-bar',
      title: 'yt-formatted-string',
      iconPlacement: 'append',
      priority: 3,
    },
  };

  // ===== DATA CACHING =====

  const CACHE_LIMIT = 10000;
  const EVICTION_BATCH_SIZE = 20;

  const brandingCache = new Map();
  const durationCache = new Map();

  const getCachedBranding = (videoID) => {
    if (!DEARROW_CONFIG.cacheEnabled) return null;

    const cached = brandingCache.get(videoID);
    if (!cached) return null;
    cached.lastUsed = Date.now();
    return cached.data;
  };

  const cacheBrandingData = (videoID, data) => {
    if (!DEARROW_CONFIG.cacheEnabled) return;

    brandingCache.set(videoID, {
      data: data,
      lastUsed: Date.now(),
      fullReply: true,
    });
    if (brandingCache.size > CACHE_LIMIT) {
      const numberToDelete = brandingCache.size - CACHE_LIMIT + EVICTION_BATCH_SIZE;

      // Sort by lastUsed and delete oldest entries
      const sortedEntries = Array.from(brandingCache.entries())
        .sort((a, b) => a[1].lastUsed - b[1].lastUsed);

      for (let i = 0; i < numberToDelete && i < sortedEntries.length; i++) {
        brandingCache.delete(sortedEntries[i][0]);
      }

      if (DEARROW_CONFIG.debugMode) {
        console.log(`DeArrow: Cache limit exceeded, evicted ${numberToDelete} oldest entries. Cache size: ${brandingCache.size}`);
      }
    }
  };

  // ===== UTILITY FUNCTIONS =====

  const cleanEmojis = (title) => {
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
    title = title.replace(/\s+/g, ' ').trim();
    if (DEARROW_CONFIG.cleanEmojis) {
      title = cleanEmojis(title);
    }
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
        if (index === 0 || index === words.length - 1) {
          return word.charAt(0).toUpperCase() + word.slice(1);
        }
        if (smallWords.includes(word)) {
          return word;
        }
        return word.charAt(0).toUpperCase() + word.slice(1);
      })
      .join(' ');
  };

  const formatTitle = (title, isCustom) => {
    title = title.replace(/\s+/g, ' ').trim();
    if (DEARROW_CONFIG.cleanEmojis) {
      title = cleanEmojis(title);
    }
    if (DEARROW_CONFIG.titleFormatting === 'original') {
      return title;
    }
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
    if (context === 'watch') {
      const urlParams = new URLSearchParams(window.location.search);
      const videoID = urlParams.get('v');
      if (videoID) return videoID;
      return null;
    }
    const link = element.querySelector('a[href*="watch?v="], a[href*="/shorts/"]');
    if (link) {
      const match = link.href.match(/(?:watch\?v=|shorts\/)([a-zA-Z0-9_-]{11})/);
      if (match) return match[1];
    }

    const thumbnail = element.querySelector('a#thumbnail');
    if (thumbnail) {
      const match = thumbnail.href.match(/(?:watch\?v=|shorts\/)([a-zA-Z0-9_-]{11})/);
      if (match) return match[1];
    }

    return null;
  };

  // ===== API INTEGRATION =====

  const activeRequests = new Map();
  const ENABLE_DUAL_FETCH = true;
  const sha256 = async (message) => {
    const msgBuffer = new TextEncoder().encode(message);
    const hashBuffer = await crypto.subtle.digest('SHA-256', msgBuffer);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
    return hashHex;
  };

  const getHashPrefix = async (videoID) => {
    const hash = await sha256(videoID);
    return hash.slice(0, 4);
  };

  const fetchFromThumbnailCache = async (videoID) => {
    try {
      const url = `${DEARROW_CONFIG.thumbnailCacheServer}/api/v1/branding/${videoID}`;

      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), DEARROW_CONFIG.fetchTimeout);

      const response = await fetch(url, {
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      if (!response.ok) {
        return null;
      }

      const data = await response.json();

      return {
        videoID,
        data,
        source: 'thumbnail-cache'
      };
    } catch (error) {
      if (DEARROW_CONFIG.debugMode && error.name !== 'AbortError') {
        console.log('DeArrow: Thumbnail cache fetch failed for', videoID, error);
      }
      return null;
    }
  };

  const fetchBrandingData = async (videoID, queryByHash = false, waitForFullReply = false) => {
    const cached = getCachedBranding(videoID);
    if (cached !== null) {
      const cachedEntry = brandingCache.get(videoID);
      if (waitForFullReply && cachedEntry && !cachedEntry.fullReply) {
        if (DEARROW_CONFIG.debugMode) {
          console.log('DeArrow: Have thumbnail cache data, fetching full reply for', videoID);
        }
      } else {
        return cached;
      }
    }

    if (activeRequests.has(videoID)) {
      return activeRequests.get(videoID);
    }
    const requestPromise = (async () => {
      try {
        let url;

        const fetchMainAPI = async () => {
          if (queryByHash) {
            const hashPrefix = await getHashPrefix(videoID);
            url = `${DEARROW_CONFIG.apiServer}/api/branding/${hashPrefix}?fetchAll=true`;
            if (DEARROW_CONFIG.debugMode) {
              console.log(`DeArrow: Fetching batch for hash prefix ${hashPrefix} (includes ${videoID})`);
            }
          } else {
            url = `${DEARROW_CONFIG.apiServer}/api/branding?videoID=${videoID}&fetchAll=true`;
          }

          const controller = new AbortController();
          const timeoutId = setTimeout(() => controller.abort(), DEARROW_CONFIG.fetchTimeout);

          const response = await fetch(url, {
            signal: controller.signal,
          });

          clearTimeout(timeoutId);

          if (!response.ok) {
            return {
              videoID,
              data: {
                titles: [],
                thumbnails: [],
                randomTime: null,
                videoDuration: null,
              },
              source: 'main-api'
            };
          }

          const data = await response.json();

          return {
            videoID,
            data: data,
            source: 'main-api',
            isHash: queryByHash
          };
        };
        const mainAPIPromise = fetchMainAPI();
        let fastestResult;

        if (ENABLE_DUAL_FETCH && !queryByHash && !waitForFullReply) {
          const thumbnailCachePromise = fetchFromThumbnailCache(videoID);
          fastestResult = await Promise.race([
            mainAPIPromise.then(r => r || null),
            thumbnailCachePromise.then(r => r || null)
          ]);

          mainAPIPromise.then(mainResult => {
            if (mainResult && mainResult.source === 'main-api') {
              cacheBrandingData(videoID, mainResult.data);
            }
          }).catch(() => {});
        } else {
          fastestResult = await mainAPIPromise;
        }

        if (!fastestResult) {
          return {
            titles: [],
            thumbnails: [],
            randomTime: null,
            videoDuration: null,
          };
        }

        if (fastestResult.isHash) {
          const results = fastestResult.data;

          if (!results[videoID]) {
            results[videoID] = {
              titles: [],
              thumbnails: [],
              randomTime: null,
              videoDuration: null,
            };
          }

          for (const [batchVideoID, batchData] of Object.entries(results)) {
            cacheBrandingData(batchVideoID, batchData);
          }

          if (DEARROW_CONFIG.debugMode) {
            console.log(`DeArrow: Fetched batch of ${Object.keys(results).length} videos (requested ${videoID})`);
          }

          return results[videoID];
        } else {
          const fullReply = fastestResult.source === 'main-api';
          brandingCache.set(videoID, {
            data: fastestResult.data,
            lastUsed: Date.now(),
            fullReply: fullReply
          });

          if (DEARROW_CONFIG.debugMode) {
            console.log(`DeArrow: Fetched data for ${videoID} from ${fastestResult.source}`);
          }

          return fastestResult.data;
        }
      } catch (error) {
        if (DEARROW_CONFIG.debugMode) {
          console.error('DeArrow: Fetch error for', videoID, error);
        }
        return null;
      } finally {
        activeRequests.delete(videoID);
      }
    })();

    activeRequests.set(videoID, requestPromise);
    return requestPromise;
  };

  // ===== ICON IMPLEMENTATION =====

  const createDeArrowIcon = (originalTitle, modifiedTitle, context) => {
    const container = document.createElement('span');
    container.className = 'dearrow-icon-container';

    if (context === 'watch') {
      container.classList.add('dearrow-always-visible');
    }
    const button = document.createElement('button');
    button.className = 'yt-spec-button-shape-next yt-spec-button-shape-next--tonal yt-spec-button-shape-next--mono yt-spec-button-shape-next--size-s yt-spec-button-shape-next--icon-only-default';
    button.title = 'DeArrow: Hover to see original';
    button.dataset.originalTitle = originalTitle;
    button.dataset.dearrowTitle = modifiedTitle;

    const iconWrapper = document.createElement('div');
    iconWrapper.className = 'yt-spec-button-shape-next__icon';
    iconWrapper.setAttribute('aria-hidden', 'true');
    iconWrapper.style.cssText = 'display: flex; align-items: center; justify-content: center;';

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
      if (parent) {
        parent.style.display = 'flex';
        parent.style.alignItems = 'flex-start';
        parent.style.flexWrap = 'nowrap';
        parent.style.gap = '8px';
        parent.style.width = '100%';
      }

      titleElement.style.flex = '1 1 0';
      titleElement.style.minWidth = '0';
      titleElement.parentNode.insertBefore(icon, titleElement.nextSibling);
    } else if (placement === 'inline') {
      if (parent) {
        parent.style.position = 'relative';
        parent.style.paddingRight = '36px';
      }

      icon.style.position = 'absolute';
      icon.style.top = '0';
      icon.style.right = '20px';
      icon.style.transform = 'scale(0.75)';
      icon.style.transformOrigin = 'top right';
      titleElement.parentNode.appendChild(icon);
    }
  };

  const setupIconHover = (iconContainer, titleElement, originalTitle, modifiedTitle, thumbnailElement = null) => {
    if (!DEARROW_CONFIG.hoverShowsOriginal) return;

    const button = iconContainer.querySelector('button');

    button.addEventListener('mouseenter', () => {
      titleElement.textContent = originalTitle;
      titleElement.setAttribute('title', originalTitle);
      if (thumbnailElement && thumbnailElement.dataset.dearrowOriginalSrc) {
        thumbnailElement.dataset.dearrowCurrentSrc = thumbnailElement.src;
        thumbnailElement.src = thumbnailElement.dataset.dearrowOriginalSrc;
      }
    });

    button.addEventListener('mouseleave', () => {
      titleElement.textContent = modifiedTitle;
      titleElement.setAttribute('title', modifiedTitle);
      if (thumbnailElement && thumbnailElement.dataset.dearrowCurrentSrc) {
        thumbnailElement.src = thumbnailElement.dataset.dearrowCurrentSrc;
      }
    });
  };

  // ===== MAIN PROCESSING LOGIC =====

  const shouldProcessTitle = () => DEARROW_CONFIG.replaceTitles;
  const shouldProcessThumbnail = () => DEARROW_CONFIG.replaceThumbnails;

  const processVideoTitle = async (element, context) => {
    try {
      if (!shouldProcessTitle()) return;

      const videoID = extractVideoID(element, context);
      if (!videoID) {
        if (DEARROW_CONFIG.debugMode)
          console.log('DeArrow: No video ID found for context:', context);
        return;
      }

      const contextConfig = TITLE_CONTEXTS[context];
      const titleElement = element.querySelector(contextConfig.title);
      if (!titleElement) {
        return;
      }

      const originalTitle = titleElement.textContent.trim();
      if (!originalTitle) return;

      if (titleElement.dataset.dearrowProcessed) return;
      titleElement.dataset.dearrowProcessed = 'true';

      const queryByHash = (context === 'watch' || context === 'related');
      const brandingData = await fetchBrandingData(videoID, queryByHash);

      let newTitle;
      let isCustom = false;

      if (
        brandingData?.titles?.[0] &&
        brandingData.titles[0].votes >= 0 &&
        DEARROW_CONFIG.useCrowdsourcedTitles
      ) {
        newTitle = brandingData.titles[0].title;
        isCustom = true;
        if (DEARROW_CONFIG.formatCustomTitles) {
          newTitle = formatTitle(newTitle, isCustom);
        }
      } else {
        newTitle = formatTitle(originalTitle, false);
      }

      if (newTitle === originalTitle) return;

      titleElement.textContent = newTitle;
      titleElement.setAttribute('title', newTitle);

      let thumbnailElement = null;
      if (shouldProcessThumbnail()) {
        thumbnailElement = await processVideoThumbnail(element, videoID, brandingData);
      }

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

  const alea = (seed) => {
    seed = seed.toString();
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
      return (n >>> 0) * 2.3283064365386963e-10;
    };

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

    return () => {
      const t = 2091639 * s0 + c * 2.3283064365386963e-10;
      s0 = s1;
      s1 = s2;
      return s2 = t - (c = t | 0);
    };
  };

  const fetchVideoMetadata = async (videoID) => {
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

      if (!response.ok) return null;

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
      return null;
    }
  };

  // ===== THUMBNAIL PROCESSING =====

  const isStillValid = (element, videoID) => {
    if (!document.contains(element)) return false;
    const currentVideoID = extractVideoID(element, 'related');
    if (currentVideoID !== videoID) return false;
    return true;
  };

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
    const selectors = [
      'img#img',
      'img.yt-core-image',
      'yt-image img',
      'ytd-thumbnail img',
      'a#thumbnail img',
      '.yt-lockup-view-model img',
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
    if (brandingData?.videoDuration) {
      return brandingData.videoDuration;
    }
    const videoData = element.querySelector('a[href*="watch"]');
    if (videoData) {
      const durationAttr = videoData.getAttribute('data-duration') || videoData.getAttribute('aria-label');
      if (durationAttr) {
        const match = durationAttr.match(/(\d+):(\d+)(?::(\d+))?/);
        if (match) {
          const hours = match[3] ? parseInt(match[1], 10) : 0;
          const minutes = match[3] ? parseInt(match[2], 10) : parseInt(match[1], 10);
          const seconds = match[3] ? parseInt(match[3], 10) : parseInt(match[2], 10);
          const duration = hours * 3600 + minutes * 60 + seconds;
          if (duration > 0 && duration < 86400) {
            return duration;
          }
        }
      }
    }

    const timeSelectors = [
      'ytd-thumbnail-overlay-time-status-renderer span.style-scope.ytd-thumbnail-overlay-time-status-renderer',
      'ytd-thumbnail-overlay-time-status-renderer #text',
      '.ytd-thumbnail-overlay-time-status-renderer #text',
      '#overlays #text',
      '.badge-shape-wiz__text',
      'span.ytd-thumbnail-overlay-time-status-renderer',
      '.ytp-time-duration',
    ];

    for (const selector of timeSelectors) {
      try {
        const timeDisplay = element.querySelector(selector);
        if (timeDisplay && timeDisplay.textContent) {
          const timeText = timeDisplay.textContent.trim();
          const match = timeText.match(/^(\d+):(\d+)(?::(\d+))?$/);
          if (match) {
            const hours = match[3] ? parseInt(match[1], 10) : 0;
            const minutes = match[3] ? parseInt(match[2], 10) : parseInt(match[1], 10);
            const seconds = match[3] ? parseInt(match[3], 10) : parseInt(match[2], 10);
            const duration = hours * 3600 + minutes * 60 + seconds;
            if (duration > 0 && duration < 86400) {
              return duration;
            }
          }
        }
      } catch (e) {}
    }

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

      const hourMatch = ariaLabel.match(/(\d+)\s+hour/i);
      const minMatch = ariaLabel.match(/(\d+)\s+minute/i);
      const secMatch = ariaLabel.match(/(\d+)\s+second/i);

      if (minMatch || secMatch || hourMatch) {
        const hours = hourMatch ? parseInt(hourMatch[1], 10) : 0;
        const minutes = minMatch ? parseInt(minMatch[1], 10) : 0;
        const seconds = secMatch ? parseInt(secMatch[1], 10) : 0;
        const duration = hours * 3600 + minutes * 60 + seconds;
        if (duration > 0) {
          return duration;
        }
      }
    }

    if (window.location.pathname === '/watch') {
      const player = document.querySelector('video');
      if (player && player.duration && !isNaN(player.duration) && player.duration > 0) {
        return player.duration;
      }
    }

    if (videoID) {
      const duration = await fetchVideoMetadata(videoID);
      if (duration) {
        return duration;
      }
    }

    return null;
  };

  // ===== THUMBNAIL QUEUE SYSTEM =====

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
    if (activeThumbnailRequests.has(videoID)) {
      return activeThumbnailRequests.get(videoID);
    }

    const promise = new Promise((resolve) => {
      thumbnailQueue.push({ resolve, videoID, element, brandingData });
      processThumbnailQueue();
    });

    activeThumbnailRequests.set(videoID, promise);
    return promise;
  };

  const processVideoThumbnailInternal = async (element, videoID, brandingData) => {
    try {
      if (DEARROW_CONFIG.thumbnailFallback === 'original' &&
          (!brandingData?.thumbnails?.[0] || brandingData.thumbnails[0].votes < 0)) {
        return null;
      }

      const thumbnailImg = findThumbnailImage(element);
      if (!thumbnailImg) return null;

      if (thumbnailImg.dataset.dearrowProcessed) {
        return thumbnailImg;
      }
      thumbnailImg.dataset.dearrowProcessed = 'true';

      const originalSrc = thumbnailImg.src;
      thumbnailImg.dataset.dearrowOriginalSrc = originalSrc;

      const shouldHideWhileFetching = DEARROW_CONFIG.hideWhileFetching &&
        (brandingData?.thumbnails?.[0] || brandingData?.randomTime !== null);

      if (!shouldHideWhileFetching) {
        thumbnailImg.classList.add('cb-visible');
      }

      // Get thumbnail data
      let thumbnailTime = null;
      let isOfficialTime = false;

      if (brandingData?.thumbnails?.[0] && brandingData.thumbnails[0].votes >= 0) {
        thumbnailTime = brandingData.thumbnails[0].timestamp;
        isOfficialTime = true;
      }
      else if (brandingData?.randomTime !== null && brandingData?.randomTime !== undefined) {
        let duration = brandingData.videoDuration;
        if (!duration) {
          duration = await getVideoDuration(element, videoID, brandingData);
        }

        if (duration) {
          let randomTime = brandingData.randomTime;
          if (randomTime > 0.9) {
            randomTime -= 0.9;
          }
          thumbnailTime = randomTime * duration;
          isOfficialTime = false;
        } else {
          thumbnailImg.classList.add('cb-visible');
          return null;
        }
      }
      else if (DEARROW_CONFIG.thumbnailFallback === 'randomTime') {
        let duration = brandingData?.videoDuration;
        if (!duration) {
          duration = await getVideoDuration(element, videoID, brandingData);
        }

        if (duration) {
          const rng = alea(videoID);
          let randomFraction = rng();
          if (randomFraction > 0.9) {
            randomFraction -= 0.9;
          }
          thumbnailTime = randomFraction * duration;
          isOfficialTime = false;
        } else {
          thumbnailImg.classList.add('cb-visible');
          return null;
        }
      }

      if (thumbnailTime === null) {
        thumbnailImg.classList.add('cb-visible');
        return null;
      }

      if (!isStillValid(element, videoID)) {
        return null;
      }

      const cachedThumbnailUrl = getThumbnailUrl(videoID, thumbnailTime, false, isOfficialTime);
      const generateUrl = getThumbnailUrl(videoID, thumbnailTime, true, isOfficialTime);
      const preloadImage = new Image();

      try {
        await new Promise((resolve, reject) => {
          preloadImage.onload = resolve;
          preloadImage.onerror = () => {
            const generateImg = new Image();
            generateImg.onload = () => resolve(generateUrl);
            generateImg.onerror = reject;
            generateImg.src = generateUrl;
          };
          preloadImage.src = cachedThumbnailUrl;
        });

        if (!isStillValid(element, videoID)) {
          return null;
        }

        thumbnailImg.src = preloadImage.src === cachedThumbnailUrl ? cachedThumbnailUrl : generateUrl;
        thumbnailImg.srcset = '';

        await new Promise((resolve) => {
          if (thumbnailImg.complete) {
            resolve();
          } else {
            thumbnailImg.addEventListener('load', resolve, { once: true });
          }
        });

        if (!isStillValid(element, videoID)) {
          return null;
        }

        thumbnailImg.classList.add('cb-visible');
        return thumbnailImg;

      } catch (error) {
        if (DEARROW_CONFIG.thumbnailFallbackOnError === 'blank') {
          thumbnailImg.src = 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="16" height="9"%3E%3Crect fill="%23282828" width="16" height="9"/%3E%3C/svg%3E';
        } else {
          thumbnailImg.src = originalSrc;
        }
        thumbnailImg.classList.add('cb-visible');
        return null;
      }
    } catch (error) {
      const thumbnailImg = findThumbnailImage(element);
      if (thumbnailImg) {
        thumbnailImg.classList.add('cb-visible');
      }
      return null;
    }
  };

  // ===== DOM OBSERVATION =====

  let lastThumbnailCheck = 0;
  let thumbnailCheckTimeout = null;
  const DEBOUNCE_DELAY = 50;
  let lastGarbageCollection = 0;
  const GARBAGE_COLLECTION_INTERVAL = 5000;

  const runGarbageCollection = () => {
    const now = performance.now();
    if (now - lastGarbageCollection < GARBAGE_COLLECTION_INTERVAL) return;
    lastGarbageCollection = now;
  };

  const setupIntersectionObserver = () => {
    if (window.dearrowIntersectionObserver) return;

    let batchedElements = [];
    let batchTimeout = null;

    const processBatch = () => {
      if (batchedElements.length === 0) return;

      const promises = batchedElements.map(({ element, context }) => {
        return processVideoTitle(element, context).catch((error) => {
          if (DEARROW_CONFIG.debugMode) {
            console.error('DeArrow: Error processing video in batch:', error);
          }
        });
      });

      Promise.all(promises);
      batchedElements = [];
      batchTimeout = null;
    };

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            const element = entry.target;
            const context = element.matches(TITLE_CONTEXTS.related.container) ? 'related' : element;
            batchedElements.push({ element, context });
            if (batchTimeout) clearTimeout(batchTimeout);
            batchTimeout = setTimeout(processBatch, 50);
            observer.unobserve(element);
          }
        });
      },
      {
        root: null,
        rootMargin: '100px',
        threshold: 0.1,
      }
    );

    const videos = document.querySelectorAll(
      `${TITLE_CONTEXTS.related.container}`
    );
    videos.forEach((video) => {
      if (!video.dataset.dearrowObserved) {
        video.dataset.dearrowObserved = 'true';
        observer.observe(video);
      }
    });

    window.dearrowIntersectionObserver = observer;

    let mutationTimeout = null;
    const mutationObserver = new MutationObserver(() => {
      clearTimeout(mutationTimeout);
      mutationTimeout = setTimeout(() => {
        const newVideos = document.querySelectorAll(
          `${TITLE_CONTEXTS.related.container}:not([data-dearrow-observed])`
        );
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
    const delay = 1000;
    let lastProcessedWatchUrl = null;

    const processWatchPageDebounced = () => {
      const now = performance.now();
      if (now - lastThumbnailCheck < DEBOUNCE_DELAY || thumbnailCheckTimeout) {
        if (!thumbnailCheckTimeout) {
          thumbnailCheckTimeout = setTimeout(() => {
            thumbnailCheckTimeout = null;
            lastThumbnailCheck = performance.now();
            processWatchPageImmediate();
          }, DEBOUNCE_DELAY);
        }
        return;
      }

      lastThumbnailCheck = now;
      processWatchPageImmediate();
    };

    const processWatchPageImmediate = () => {
      if (!window.location.pathname.includes('/watch') || !window.location.search.includes('v=')) {
        lastProcessedWatchUrl = null;
        return;
      }

      const currentUrl = window.location.href;
      if (currentUrl === lastProcessedWatchUrl) return;

      const watchContainer = document.querySelector(TITLE_CONTEXTS.watch.container);
      if (watchContainer) {
        lastProcessedWatchUrl = currentUrl;
        processVideoTitle(watchContainer, 'watch');
      }
    };

    const processRelatedVideos = () => {
      if (DEARROW_CONFIG.lazyLoadRelated) {
        setupIntersectionObserver();
      } else {
        const videos = document.querySelectorAll(
          `${TITLE_CONTEXTS.related.container}`
        );
        videos.forEach((video) => {
          processVideoTitle(video, 'related');
        });
      }
    };

    if (!window.dearrowIntervalID) {
      window.dearrowIntervalID = setInterval(() => {
        processWatchPageDebounced();
        processRelatedVideos();
        runGarbageCollection();
      }, delay);
    }
  };

  // ===== CSS STYLING =====

  const injectStyles = () => {
    const style = document.createElement('style');

    const allContainers = new Set([
      ...TITLE_CONTEXTS.related.container.split(', '),
    ]);

    const titleLineClampRules = [];
    for (const container of allContainers) {
      titleLineClampRules.push(`${container} #video-title:not(.ta-title-container)`);
      titleLineClampRules.push(`${container} .yt-lockup-metadata-view-model__title:not(.ta-title-container)`);
      titleLineClampRules.push(
        `${container} .yt-lockup-metadata-view-model__title > .yt-core-attributed-string:not(.ta-title-container)`
      );
    }

    const cssContent = `
      .dearrow-custom-title {
        display: inline;
      }

      .dearrow-original-title {
        display: none;
      }

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

      .dearrow-icon-container.dearrow-always-visible {
        display: inline-flex !important;
      }

      *:hover > .dearrow-icon-container:not(.dearrow-always-visible) {
        display: inline-flex !important;
      }

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

      #video-title .dearrow-icon-container {
        margin-left: 4px;
      }

      ytd-watch-metadata .dearrow-icon-container {
        vertical-align: middle;
      }

      .dearrow-icon-circle {
        stroke: var(--system-theme-blue, #3ea6ff);
        transition: stroke 0.2s ease;
      }

      .dearrow-icon-container button:hover .dearrow-icon-circle {
        stroke: var(--system-theme-grey2, #aaa);
      }

      .yt-lockup-metadata-view-model__text-container {
        width: 100%;
      }
    `;

    style.textContent = cssContent;
    document.head.appendChild(style);
  };

  // ===== INITIALIZATION =====

  const init = () => {
    if (window.dearrowInitialized) return;
    injectStyles();
    observeYouTubePage();
    window.dearrowInitialized = true;
  };

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();

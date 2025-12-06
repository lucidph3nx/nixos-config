// ==UserScript==
// @name         SponsorBlock
// @version      2.1.0
// @description  Skip sponsor and other unwanted segments, show labels in tooltips, and apply colors on the seek bar for YouTube
// @match        *://*.youtube.com/*
// @exclude      *://*.youtube.com/subscribe_embed?*
// ==/UserScript==

const delay = 1000;

// Configuration for segment categories
const CATEGORY_SETTINGS = {
  sponsor: {
    color: 'var(--system-theme-green)',
    label: 'Sponsor',
    skip: true,
    priority: 1
  },
  selfpromo: {
    color: 'var(--system-theme-yellow)',
    label: 'Unpaid/Self Promotion',
    skip: true,
    priority: 2
  },
  interaction: {
    color: 'var(--system-theme-purple)',
    label: 'Interaction Reminder',
    skip: true,
    priority: 2
  },
  intro: {
    color: 'var(--system-theme-aqua)',
    label: 'Intermission/Intro',
    skip: false,
    priority: 2
  },
  outro: {
    color: 'var(--system-theme-blue)',
    label: 'Endcards/Credits',
    skip: false,
    priority: 2
  },
  preview: {
    color: 'var(--system-theme-blue)',
    label: 'Preview/Recap/Hook',
    skip: false,
    priority: 2
  },
  music_offtopic: {
    color: 'var(--system-theme-orange)',
    label: 'Non-Music Section',
    skip: false,
    priority: 2
  },
  filler: {
    color: 'var(--system-theme-purple)',
    label: 'Filler',
    skip: false,
    priority: 3
  },
};

const fetchSegments = (videoID) => {
  const categories = encodeURIComponent(
    JSON.stringify(Object.keys(CATEGORY_SETTINGS))
  );
  return fetch(
    `https://sponsor.ajay.app/api/skipSegments?videoID=${videoID}&categories=${categories}`
  )
    .then((res) => res.json())
    .catch((e) => console.error(`Sponsorblock fetch failed: ${e}`) || []);
};

const getHighestPriorityCategory = (categories) => {
  return categories.reduce((highest, category) => {
    const priority = CATEGORY_SETTINGS[category]?.priority ?? Number.MAX_VALUE;
    const highestPriority = CATEGORY_SETTINGS[highest]?.priority ?? Number.MAX_VALUE;
    return priority < highestPriority ? category : highest;
  });
};

const createCategoryIndicators = (segments) => {
  // Look for the parent element that contains the progress bar
  const progressBarContainer = document.querySelector('.ytp-progress-bar-container');
  if (!progressBarContainer) return;

  const video = document.querySelector('video');
  if (!video || Number.isNaN(video.duration)) return;

  // Find or create the preview bar container
  let previewBar = document.getElementById('sb-previewbar');
  if (!previewBar) {
    previewBar = document.createElement('ul');
    previewBar.id = 'sb-previewbar';
    previewBar.style.cssText = `
      overflow: visible;
      padding: 0;
      margin: 0;
      position: absolute;
      width: 100%;
      pointer-events: none;
      height: 100%;
      transform: scaleY(0.667) translateY(-30%) translateY(1.5px);
      z-index: 42;
      transition: transform .1s cubic-bezier(0,0,0.2,1);
    `;
    
    // Prepend to the progress bar container
    progressBarContainer.prepend(previewBar);
  } else {
    // Clear existing segments
    while (previewBar.firstChild) {
      previewBar.removeChild(previewBar.firstChild);
    }
  }

  // Sort segments by length (longest first) so shorter segments render on top
  const sortedSegments = [...segments].sort((a, b) => {
    const lengthA = a.segment[1] - a.segment[0];
    const lengthB = b.segment[1] - b.segment[0];
    return lengthB - lengthA;
  });

  sortedSegments.forEach(({ segment, category }) => {
    const [start, end] = segment;
    const categoryConfig = CATEGORY_SETTINGS[category] || {};
    if (!categoryConfig.color) return;

    const indicator = document.createElement('li');
    indicator.className = 'sb-category-indicator';
    indicator.style.cssText = `
      display: inline-block;
      height: 100%;
      min-width: 1px;
      position: absolute;
      background-color: ${categoryConfig.color};
      opacity: 0.7;
      left: ${(start / video.duration) * 100}%;
      right: ${(1 - (end / video.duration)) * 100}%;
      pointer-events: none;
    `;
    
    previewBar.appendChild(indicator);
  });
};

const setupCategoryTooltip = (segments) => {
  // Use multiple selectors like the official extension
  const seekBar = document.querySelector('.ytp-progress-bar-container, .ypcs-scrub-slider-slot.ytu-player-controls');
  if (!seekBar) return false;
  
  // Check if we've already set up listeners on this seekBar
  if (window.sbTooltipSeekBar === seekBar) return true;
  
  // Remove old event listeners if they exist
  if (window.sbTooltipSeekBar && window.sbTooltipMouseEnter && window.sbTooltipMouseLeave && window.sbTooltipMouseMove) {
    window.sbTooltipSeekBar.removeEventListener('mouseenter', window.sbTooltipMouseEnter);
    window.sbTooltipSeekBar.removeEventListener('mouseleave', window.sbTooltipMouseLeave);
    window.sbTooltipSeekBar.removeEventListener('mousemove', window.sbTooltipMouseMove);
  }

  const video = document.querySelector('video');
  if (!video || Number.isNaN(video.duration)) return false;

  // Multiple fallback selectors for tooltip wrapper, matching the official extension
  const tooltipTextWrapper = document.querySelector('.ytp-tooltip-text-wrapper, .ytp-progress-tooltip-text-container, .yssi-slider .ys-seek-details .time-info-bar') 
    || document.querySelector('#progress-bar-container.ytk-player > #hover-time-info');
  
  if (!tooltipTextWrapper) return false;

  const tooltipContainer = tooltipTextWrapper.parentElement;
  
  // Multiple selectors for the title tooltip
  const titleTooltip = tooltipTextWrapper.querySelector('.ytp-tooltip-title, .ytp-progress-tooltip-text, .current-time');
  if (!tooltipContainer || !titleTooltip) return false;

  // Remove old category tooltip if it exists
  const oldTooltip = tooltipTextWrapper.querySelector('.sb-sponsorCategoryTooltip');
  if (oldTooltip) {
    oldTooltip.remove();
  }

  // Create our category tooltip element
  const categoryTooltip = document.createElement('div');
  categoryTooltip.className = 'ytp-tooltip-title sb-sponsorCategoryTooltip';
  // Insert it after the main title tooltip (before nextSibling inserts it right after)
  tooltipTextWrapper.insertBefore(categoryTooltip, titleTooltip.nextSibling);
  
  // Store reference globally for recreation check
  window.sbCategoryTooltip = categoryTooltip;

  let mouseOnSeekBar = false;

  window.sbTooltipMouseEnter = () => {
    mouseOnSeekBar = true;
  };

  window.sbTooltipMouseLeave = () => {
    mouseOnSeekBar = false;
    tooltipContainer.classList.remove('sb-sponsorCategoryTooltipVisible');
  };

  window.sbTooltipMouseMove = (e) => {
    if (!mouseOnSeekBar) return;

    // Use the global reference
    let categoryTooltip = window.sbCategoryTooltip;
    
    // Check if tooltip element still exists in DOM, recreate if needed
    if (!categoryTooltip || !document.body.contains(categoryTooltip)) {
      const newCategoryTooltip = document.createElement('div');
      newCategoryTooltip.className = 'ytp-tooltip-title sb-sponsorCategoryTooltip';
      tooltipTextWrapper.insertBefore(newCategoryTooltip, titleTooltip.nextSibling);
      // Update the reference
      window.sbCategoryTooltip = newCategoryTooltip;
      categoryTooltip = newCategoryTooltip;
    }

    const rect = seekBar.getBoundingClientRect();
    const timeInSeconds = ((e.clientX - rect.x) / seekBar.clientWidth) * video.duration;

    // Find segments at this time position, prefer shortest segment
    const overlappingSegments = segments
      .filter(({ segment }) => timeInSeconds >= segment[0] && timeInSeconds <= segment[1])
      .sort((a, b) => {
        const lengthA = a.segment[1] - a.segment[0];
        const lengthB = b.segment[1] - b.segment[0];
        return lengthA - lengthB; // Sort by length, shortest first
      });

    if (overlappingSegments.length > 0) {
      const highestPriorityCategory = getHighestPriorityCategory(
        overlappingSegments.map(({ category }) => category)
      );
      const label = CATEGORY_SETTINGS[highestPriorityCategory]?.label || highestPriorityCategory;

      categoryTooltip.textContent = label;
      tooltipContainer.classList.add('sb-sponsorCategoryTooltipVisible');
      
      // Match alignment with the title tooltip
      categoryTooltip.style.right = titleTooltip.style.right;
      categoryTooltip.style.textAlign = titleTooltip.style.textAlign;
    } else {
      tooltipContainer.classList.remove('sb-sponsorCategoryTooltipVisible');
    }
  };

  seekBar.addEventListener('mouseenter', window.sbTooltipMouseEnter);
  seekBar.addEventListener('mouseleave', window.sbTooltipMouseLeave);
  seekBar.addEventListener('mousemove', window.sbTooltipMouseMove);
  
  // Monitor tooltip container for class changes by YouTube
  if (window.sbTooltipObserver) {
    window.sbTooltipObserver.disconnect();
  }
  window.sbTooltipObserver = new MutationObserver((mutations) => {
    mutations.forEach((mutation) => {
      if (mutation.type === 'attributes' && mutation.attributeName === 'class') {
        // Silently monitor for changes - this helps maintain tooltip visibility
      }
    });
  });
  window.sbTooltipObserver.observe(tooltipContainer, {
    attributes: true,
    attributeFilter: ['class']
  });
  
  window.sbTooltipSeekBar = seekBar;
  return true;
};

const skipSegments = async () => {
  const videoID = new URL(document.location).searchParams.get('v');
  if (!videoID) return;

  const key = `segmentsToSkip-${videoID}`;
  window[key] =
    window[key] || (await fetchSegments(videoID));

  createCategoryIndicators(window[key]);
  
  // Set up tooltip with a delay to ensure DOM is ready
  // Try multiple times in case the tooltip isn't loaded yet
  let tooltipAttempts = 0;
  const trySetupTooltip = () => {
    const success = setupCategoryTooltip(window[key]);
    if (!success && tooltipAttempts < 5) {
      tooltipAttempts++;
      setTimeout(trySetupTooltip, 500);
    }
  };
  setTimeout(trySetupTooltip, 200);

  const video = document.querySelector('video');
  if (!video) return;

  for (const { segment: [start, end], category } of window[key]) {
    const categoryConfig = CATEGORY_SETTINGS[category] || {};
    if (!categoryConfig.skip) continue;

    if (video.currentTime < end && video.currentTime >= start) {
      console.log(
        `Sponsorblock: skipped ${category} from ${start} to ${end}`
      );
      video.currentTime = end;
      return;
    }
    const timeToSegment = (start - video.currentTime) / video.playbackRate;
    if (video.currentTime < start && timeToSegment < delay / 1000) {
      setTimeout(skipSegments, timeToSegment * 1000);
    }
  }
};

if (!window.skipSegmentsIntervalID) {
  window.skipSegmentsIntervalID = setInterval(skipSegments, delay);
}

// Style for preview bar and hover effect
const style = document.createElement('style');
style.textContent = `
    #sb-previewbar {
        list-style: none;
    }
    div:hover > #sb-previewbar {
        transform: scaleY(1) !important;
    }
    
    /* Hide category tooltip by default */
    .ytp-tooltip:not(.sb-sponsorCategoryTooltipVisible) .sb-sponsorCategoryTooltip {
        display: none !important;
    }
    
    /* Show category tooltip when parent has visibility class */
    .ytp-tooltip.sb-sponsorCategoryTooltipVisible .sb-sponsorCategoryTooltip {
        display: block !important;
    }
    
    /* Adjust tooltip position when category is visible */
    .ytp-tooltip.sb-sponsorCategoryTooltipVisible {
        transform: translateY(-1em) !important;
    }
    
    /* Adjust wrapper to accommodate extra label */
    #movie_player:not(.ytp-big-mode) .ytp-tooltip.sb-sponsorCategoryTooltipVisible > .ytp-tooltip-text-wrapper {
        transform: translateY(1em) !important;
    }
    
    .ytp-big-mode .ytp-tooltip.sb-sponsorCategoryTooltipVisible {
        transform: translateY(-2em) !important;
    }
    
    .ytp-big-mode .ytp-tooltip.sb-sponsorCategoryTooltipVisible > .ytp-tooltip-text-wrapper {
        transform: translateY(0.5em) !important;
    }
`;
document.head.appendChild(style);

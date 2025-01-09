// ==UserScript==
// @name         Sponsorblock
// @description  Skip sponsor segments automatically
// @match        *://*.youtube.com/*
// @exclude      *://*.youtube.com/subscribe_embed?*
// ==/UserScript==
const delay = 1000;

const tryFetchSkipSegments = (videoID) =>

  // TODO: I could add a ?category=... to get and skip more than just 'sponsor' segments
  fetch(`https://sponsor.ajay.app/api/skipSegments?videoID=${videoID}`)
    .then((r) => r.json())
    .then((rJson) =>
      rJson.filter((a) => a.actionType === 'skip').map((a) => a.segment)
    )
    .catch(
      (e) =>
        console.log(
          `Sponsorblock: failed fetching skipSegments for ${videoID}, reason: ${e}`
        ) || []
    );

const createSponsorSegments = (segments) => {
  const progressBar = document.querySelector('.ytp-progress-bar');
  if (!progressBar) return;

  // Remove existing sponsor bars
  document.querySelectorAll('.sponsor-segment').forEach((el) => el.remove());

  const video = document.querySelector('video');
  if (!video || Number.isNaN(video.duration)) return;

  segments.forEach(([start, end]) => {
    const bar = document.createElement('div');
    bar.classList.add('sponsor-segment');
    bar.style.position = 'absolute';
    bar.style.height = '100%';
    bar.style.backgroundColor = 'rgba(255, 0, 0, 0.5)'; // Red color with transparency
    bar.style.left = `${(start / video.duration) * 100}%`;
    bar.style.width = `${((end - start) / video.duration) * 100}%`;

    progressBar.appendChild(bar);
  });
};

const skipSegments = async () => {
  const videoID = new URL(document.location).searchParams.get('v');
  if (!videoID) {
    return;
  }

  const key = `segmentsToSkip-${videoID}`;
  window[key] = window[key] || (await tryFetchSkipSegments(videoID));
  createSponsorSegments(window[key]);

  for (const v of document.querySelectorAll('video')) {
    if (Number.isNaN(v.duration)) continue;
    for (const [start, end] of window[key]) {
      if (v.currentTime < end && v.currentTime >= start) {
        console.log(`Sponsorblock: skipped video @${v.currentTime} from ${start} to ${end}`);
        v.currentTime = end;
        return;
      }
      const timeToSponsor = (start - v.currentTime) / v.playbackRate;
      if (v.currentTime < start && timeToSponsor < delay / 1000) {
        console.log(`Sponsorblock: Almost at sponsor segment, sleep for ${timeToSponsor * 1000}ms`);
        setTimeout(skipSegments, timeToSponsor * 1000);
      }
    }
  }
};
if (!window.skipSegmentsIntervalID) {
  window.skipSegmentsIntervalID = setInterval(skipSegments, delay);
};

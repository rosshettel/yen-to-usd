// Offline support: serve the app (and its fonts) from cache, refreshing the cache
// in the background. The rate API is not cached; the page falls back on its own.
const CACHE = 'yen-to-usd-v3';
const SHELL = [
  './',
  './index.html',
  './manifest.webmanifest',
  './icons/apple-touch-icon.png',
  './icons/icon-192.png',
  './icons/icon-512.png',
];

self.addEventListener('install', event => {
  event.waitUntil(caches.open(CACHE).then(cache => cache.addAll(SHELL)));
  self.skipWaiting();
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', event => {
  const req = event.request;
  if (req.method !== 'GET') return;

  const url = new URL(req.url);
  const isApp = url.origin === self.location.origin;
  const isFont = url.hostname === 'fonts.googleapis.com' || url.hostname === 'fonts.gstatic.com';
  if (!isApp && !isFont) return;

  // Stale-while-revalidate: answer from cache right away, update it for next launch.
  const fresh = caches.open(CACHE).then(cache =>
    fetch(req)
      .then(res => {
        if (res.ok || res.type === 'opaque') cache.put(req, res.clone());
        return res;
      })
      .catch(() => undefined)
  );
  event.waitUntil(fresh);
  event.respondWith(
    caches.match(req, { ignoreSearch: true }).then(cached =>
      cached || fresh.then(res => res || Response.error())
    )
  );
});

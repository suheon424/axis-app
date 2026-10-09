// 홈 화면 앱이 켤 때마다 파일을 다시 받지 않도록, 한 번 받은 앱 파일을 휴대폰에 저장해 둔다.
// 배포할 때 BUILD 값이 바뀌면 새 저장소를 만들고 예전 파일은 지운다.
const BUILD = 'c430175-1791550411';
const CACHE = `axis-${BUILD}`;

// 새 버전이 있는지 매번 먼저 확인해야 하는 파일. 나머지는 저장해 둔 것을 바로 쓴다.
const NETWORK_FIRST = [/\/$/, /index\.html$/, /flutter_bootstrap\.js$/, /manifest\.json$/, /version\.json$/];

self.addEventListener('install', () => self.skipWaiting());

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      const keys = await caches.keys();
      await Promise.all(keys.filter((k) => k.startsWith('axis-') && k !== CACHE).map((k) => caches.delete(k)));
      await self.clients.claim();
    })(),
  );
});

self.addEventListener('fetch', (event) => {
  const req = event.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);
  if (url.origin !== self.location.origin) return;

  const networkFirst = req.mode === 'navigate' || NETWORK_FIRST.some((re) => re.test(url.pathname));
  event.respondWith(networkFirst ? fromNetwork(req) : fromCache(req));
});

async function fromNetwork(req) {
  const cache = await caches.open(CACHE);
  try {
    const res = await fetch(req, { cache: 'no-cache' });
    if (res.ok) cache.put(req, res.clone());
    return res;
  } catch (e) {
    const hit = await cache.match(req, { ignoreSearch: true });
    if (hit) return hit;
    throw e;
  }
}

async function fromCache(req) {
  const cache = await caches.open(CACHE);
  const hit = await cache.match(req);
  if (hit) return hit;
  const res = await fetch(req);
  if (res.ok) cache.put(req, res.clone());
  return res;
}

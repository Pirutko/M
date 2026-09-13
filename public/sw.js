const CACHE = 'mostik-v5.4.0-cache';
const STATIC = [
  '/', '/app.css', '/app.js', '/icons/icon-512.png', '/icons/icon-192.png',
  '/icons/icon-maskable-512.png', '/icons/icon-maskable-192.png', '/offline.html',
  '/manifest.webmanifest', '/assets/logos/classic.webp', '/assets/logos/bull.webp',
  '/assets/logos/horizon.webp', '/assets/logos/serpent.webp', '/assets/logos/lion.webp',
  '/assets/logos/eagle.webp', '/assets/logos/elephant.webp', '/assets/logos/fox.webp',
  '/assets/logos/nest.webp', '/assets/logos/owl.webp', '/assets/logos/cyber.webp',
  '/assets/logos/cosmos.webp', '/assets/animal-icons/icon-1.webp',
  '/assets/animal-icons/icon-2.webp', '/assets/animal-icons/icon-3.webp',
  '/assets/animal-icons/icon-4.webp', '/assets/animal-icons/icon-5.webp',
  '/assets/animal-icons/icon-6.webp', '/assets/animal-icons/icon-7.webp',
  '/assets/animal-icons/icon-8.webp', '/assets/animal-icons/icon-9.webp',
  '/assets/animal-icons/icon-10.webp', '/assets/animal-icons/icon-11.webp',
  '/assets/animal-icons/icon-12.webp'
];

self.addEventListener('install', event => {
  event.waitUntil(caches.open(CACHE).then(cache => cache.addAll(STATIC)).then(() => self.skipWaiting()));
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

function dedupeAnimals(payload) {
  if (!payload || !Array.isArray(payload.animals)) return payload;
  const seenId = new Set();
  const seenIdentity = new Set();
  const animals = [];
  for (const animal of payload.animals) {
    if (!animal || typeof animal !== 'object') continue;
    const id = String(animal.id || '');
    if (id && seenId.has(id)) continue;
    if (id) seenId.add(id);
    const identity = [
      animal.owner_id || '',
      String(animal.name || '').trim().toLocaleLowerCase(),
      String(animal.species || '').trim().toLocaleLowerCase(),
      String(animal.breed || '').trim().toLocaleLowerCase()
    ].join('|');
    if (identity !== '|||') {
      if (seenIdentity.has(identity)) continue;
      seenIdentity.add(identity);
    }
    animals.push(animal);
  }
  return {...payload, animals};
}

function injectRuntimeGuard(source) {
  const patch = `
;(()=>{
  try{
    const nativeFetch=window.fetch.bind(window);
    const showSaved=(text='Сохранено')=>{
      let host=document.querySelector('#mostikToasts');
      if(!host){host=document.createElement('div');host.id='mostikToasts';host.className='mostik-toasts';document.body.appendChild(host)}
      const el=document.createElement('div');el.className='mostik-toast mostik-toast-ok show';el.textContent=text;host.appendChild(el);
      setTimeout(()=>{el.classList.remove('show');setTimeout(()=>el.remove(),300)},2400);
    };
    window.fetch=async(...args)=>{
      const req=args[0],init=args[1]||{};
      const url=typeof req==='string'?req:(req&&req.url)||'';
      const method=String(init.method||(req&&req.method)||'GET').toUpperCase();
      const response=await nativeFetch(...args);
      if(response.ok&&/\\/api\\/observations(?:[/?]|$)/.test(url)&&['POST','PUT','PATCH'].includes(method))showSaved('Сохранено');
      if(response.ok&&/\\/api\\/role(?:[/?]|$)/.test(url)&&['PUT','POST','PATCH'].includes(method))showSaved('Роль переключена');
      return response;
    };
  }catch(e){console.warn('MOSTIK runtime guard:',e)}
})();`;
  return source + patch;
}

self.addEventListener('fetch', event => {
  if (event.request.method !== 'GET') return;
  const url = new URL(event.request.url);
  if (url.origin !== self.location.origin) return;

  const isApp = url.pathname === '/app.js';
  const isAnimalsApi = url.pathname === '/api/animals';
  const staticAsset = [
    '/', '/app.css', '/app.js', '/manifest.webmanifest',
    '/assets/logos/classic.webp', '/assets/logos/bull.webp', '/assets/logos/horizon.webp',
    '/assets/logos/serpent.webp', '/assets/logos/lion.webp', '/assets/logos/eagle.webp',
    '/assets/logos/elephant.webp', '/assets/logos/fox.webp', '/assets/logos/nest.webp',
    '/assets/logos/owl.webp', '/assets/logos/cyber.webp', '/assets/logos/cosmos.webp',
    '/icons/icon-512.png', '/icons/icon-192.png', '/icons/icon-maskable-512.png',
    '/icons/icon-maskable-192.png'
  ].includes(url.pathname) || url.pathname.startsWith('/assets/animal-icons/');

  if (event.request.mode === 'navigate') {
    event.respondWith(caches.match(event.request).then(cached => cached || fetch(event.request).catch(() => caches.match('/offline.html'))));
    return;
  }

  if (isApp) {
    event.respondWith((async()=>{
      try{
        const response=await fetch(event.request,{cache:'no-store'});
        if(!response.ok)return response;
        const source=await response.text();
        return new Response(injectRuntimeGuard(source),{status:response.status,statusText:response.statusText,headers:new Headers(response.headers)});
      }catch{
        const cached=await caches.match(event.request);
        return cached||fetch(event.request);
      }
    })());
    return;
  }

  if (isAnimalsApi) {
    event.respondWith((async()=>{
      const response=await fetch(event.request);
      if(!response.ok)return response;
      try{
        const payload=await response.clone().json();
        const cleaned=dedupeAnimals(payload);
        const headers=new Headers(response.headers);
        headers.set('content-type','application/json');
        return new Response(JSON.stringify(cleaned),{status:response.status,statusText:response.statusText,headers});
      }catch{return response}
    })());
    return;
  }

  if (staticAsset) {
    event.respondWith((async()=>{
      const cached=await caches.match(event.request);
      const network=fetch(event.request).then(response=>{
        if(response.ok){const copy=response.clone();caches.open(CACHE).then(cache=>cache.put(event.request,copy))}
        return response;
      }).catch(()=>cached);
      return cached||network;
    })());
    return;
  }

  event.respondWith(caches.match(event.request).then(cached=>cached||fetch(event.request)));
});

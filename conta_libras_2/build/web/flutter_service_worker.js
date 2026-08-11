'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "cd92c969e6b5df695d5bc25f48ccc87b",
"assets/AssetManifest.bin.json": "5bfe2d9b7390f2f19cac0dbc2ef52cfc",
"assets/AssetManifest.json": "ade0f5ce993c00253fe830dc264c0751",
"assets/assets/images/acenando-removebg-preview.png": "1d1146022b08f2fae36ed56e1c393ad8",
"assets/assets/images/acenando.png": "56b8d2961b8bd5aa75ad8c078c6159b3",
"assets/assets/images/acenandoVideo.mp4": "8def102f0c81573bb800e03e30d689c2",
"assets/assets/images/Gest%25C3%25ADculo%2520_L_%2520em%2520estilo%2520vintage.png": "9031074ec8e55d0891d414554d8ecbfc",
"assets/assets/images/logoApp.png": "4370c273a9dd2004d2be8ce7187c02ec",
"assets/assets/images/logoContaLibras.png": "cef27f2aec860eada1676aadebdbce93",
"assets/assets/imagesTermos/AplicacaoFinanceira/LBS.png": "3cf8cce312e9abeede262accc24d3285",
"assets/assets/imagesTermos/AplicacaoFinanceira/RV.png": "ccda7fb2a4ad79b187c850cce890be9e",
"assets/assets/videosTermos/aplicacao_financeira.webm": "b7cb35725c79575093dca70bfede18ca",
"assets/assets/videosTermos/ativo.webm": "ff35c5cc85040ffd6a63683a92bab6a5",
"assets/assets/videosTermos/balanco_contabil.webm": "c360035099865cdd9f3dac91d6a63710",
"assets/assets/videosTermos/bens.webm": "d95efaf5735b3eecf2d241e1f2ec7408",
"assets/assets/videosTermos/caixa.webm": "3853cd632a9e9d193ad2d1d0ef31a7e6",
"assets/assets/videosTermos/capital.webm": "2165fa6b274e929f630eb1e27d59a3bc",
"assets/assets/videosTermos/capital_social.webm": "2d1fd2d2f60f1df2183d197bfcb9e00c",
"assets/assets/videosTermos/cliente_1.webm": "bb1ee9605ddb53a3736c8ec2e92f5433",
"assets/assets/videosTermos/compras_prazo.webm": "037f9da11ed66891923195a8a1d93d7c",
"assets/assets/videosTermos/contas_receber.webm": "03f42c93ff477007383a2bc3ed77facd",
"assets/assets/videosTermos/credito.webm": "261bf97fb398292cdd463057d8f846b0",
"assets/assets/videosTermos/custo_mercadoria_vendida.webm": "d02c16017a5b736e403408d57ed8175f",
"assets/assets/videosTermos/debito.webm": "d5e704cbed36aacf8ba77310f479865f",
"assets/assets/videosTermos/demonstracao_contabil.webm": "b08bc6ffa46512c2cf50719193cc741a",
"assets/assets/videosTermos/demonstracao_resultado_exercicio.webm": "e621197834694df673366bf9b9657034",
"assets/assets/videosTermos/despesas.webm": "914737b34928d9ca9bece9732b2a43cd",
"assets/assets/videosTermos/direito.webm": "02fda052a2e0fc48db6d917881ac9fa3",
"assets/assets/videosTermos/emprestimo.webm": "8223c3283a686b6f4eed2f0e1c349f56",
"assets/assets/videosTermos/estoque.webm": "0d602a8e366576e1e94dc8903305c58f",
"assets/assets/videosTermos/fato_contabil.webm": "d9162126a605a2cb20a1d18d6d0bb8db",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "abf4b87f5fd01f785c369432848716c7",
"assets/NOTICES": "deda9cd07f843d80a11da59e880ad5b0",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "c86fbd9e7b17accae76e5ad116583dc4",
"canvaskit/canvaskit.js.symbols": "38cba9233b92472a36ff011dc21c2c9f",
"canvaskit/canvaskit.wasm": "3d2a2d663e8c5111ac61a46367f751ac",
"canvaskit/chromium/canvaskit.js": "43787ac5098c648979c27c13c6f804c3",
"canvaskit/chromium/canvaskit.js.symbols": "4525682ef039faeb11f24f37436dca06",
"canvaskit/chromium/canvaskit.wasm": "f5934e694f12929ed56a671617acd254",
"canvaskit/skwasm.js": "445e9e400085faead4493be2224d95aa",
"canvaskit/skwasm.js.symbols": "741d50ffba71f89345996b0aa8426af8",
"canvaskit/skwasm.wasm": "e42815763c5d05bba43f9d0337fa7d84",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03",
"favicon.png": "9031074ec8e55d0891d414554d8ecbfc",
"flutter.js": "c71a09214cb6f5f8996a531350400a9a",
"icons/Icon-192.png": "9031074ec8e55d0891d414554d8ecbfc",
"icons/Icon-512.png": "9031074ec8e55d0891d414554d8ecbfc",
"icons/Icon-maskable-192.png": "9031074ec8e55d0891d414554d8ecbfc",
"icons/Icon-maskable-512.png": "9031074ec8e55d0891d414554d8ecbfc",
"index.html": "862102bd3baa4622cb2d6405e2c73da4",
"/": "862102bd3baa4622cb2d6405e2c73da4",
"main.dart.js": "1ffbb9dcbdecbe597d43aecdf9a5c15b",
"manifest.json": "11880fb1a59b88afe7d07c7313f685ae",
"vercel.json": "d971a41f2046bbca14e4823e6cca4dc4",
"version.json": "9e798cb13f517e71bc1ef74d6f2ffb2a"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}

'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "6ba4f3519d9ea830b6bb281573d8fd50",
"assets/AssetManifest.bin.json": "1ee5fc83ed0290bdccc2864c4f372f4a",
"assets/AssetManifest.json": "8f54de9cc99a6c9c1ce7d6dcfcd1ad2d",
"assets/assets/images/acenando-removebg-preview.png": "1d1146022b08f2fae36ed56e1c393ad8",
"assets/assets/images/acenandoVideo.mp4": "8def102f0c81573bb800e03e30d689c2",
"assets/assets/images/logoContaLibras.png": "cef27f2aec860eada1676aadebdbce93",
"assets/assets/imagesTermos/AplicacaoFinanceira/LBS.png": "3cf8cce312e9abeede262accc24d3285",
"assets/assets/imagesTermos/AplicacaoFinanceira/RV.png": "ccda7fb2a4ad79b187c850cce890be9e",
"assets/assets/imagesTermos/ativo1.png": "03788f7330155fcfb13f0df97babfbbd",
"assets/assets/imagesTermos/ativo2.png": "f13883f24d50448969befdd6489098bc",
"assets/assets/imagesTermos/balanco1.png": "ef286250b69dfb3caba4e587f63ef115",
"assets/assets/imagesTermos/balanco2.png": "73a23d48ea60458e5a061e943b8e41a8",
"assets/assets/imagesTermos/bens1.png": "a1a309ad1220b5b341f7ff06cf61d6ce",
"assets/assets/imagesTermos/bens2.png": "6bce389561cb7f98bff3a4be18691ff8",
"assets/assets/imagesTermos/caixa1.png": "36a5e4a4b345292e9e046f97f71664e9",
"assets/assets/imagesTermos/caixa2.png": "5f2a4f9417ca97b6a832fb3a2ee88909",
"assets/assets/imagesTermos/capital1.png": "f039435fd5cda3a3d86533f4119d1978",
"assets/assets/imagesTermos/capital2.png": "822788c844773d0ecb8912604ae1f73a",
"assets/assets/imagesTermos/capitalsocial1.png": "f7b76fa6b8ebf8c9ae5da8468a9b9c40",
"assets/assets/imagesTermos/capitalsocial2.png": "85467f26e23042ed2169c01af201e87a",
"assets/assets/imagesTermos/cliente1.png": "d512311f33fa31b07bce869e83c659f9",
"assets/assets/imagesTermos/cliente2.png": "06b52cfa5363c0aa7c42b9f733a9962a",
"assets/assets/imagesTermos/comprasaprazo1.png": "5ad8221df83782f3b170e92e749db71d",
"assets/assets/imagesTermos/comprasaprazo2.png": "303c50fa6f774520c909068dd3fc0224",
"assets/assets/imagesTermos/comprasavista1.png": "f24008d819f4b827bc58f6304301ba6b",
"assets/assets/imagesTermos/comprasavista2.png": "c1c298ab8c2f9c11a75fd29328096ba4",
"assets/assets/imagesTermos/contabilidade1.png": "07588467fff57d1764bd5a463e0a55b4",
"assets/assets/imagesTermos/contabilidade2.png": "9096ab1531c2cd7faa25ed2ddbf83d20",
"assets/assets/imagesTermos/contasareceber1.png": "2d68d6abe54ec16985b10d5bd0de3eb6",
"assets/assets/imagesTermos/contasareceber2.png": "804d7c8c478766c314c2e8af5b81f1da",
"assets/assets/imagesTermos/credito1.png": "c7aca624f0bdfa890509fc95256ab545",
"assets/assets/imagesTermos/credito2.png": "5ffaa9fbf57dd25aab50dcfa9aa0edb5",
"assets/assets/imagesTermos/custoDeMercadoriaVendidas1.png": "bab16062f51eb41da59bb4581d862c5f",
"assets/assets/imagesTermos/custoDeMercadoriaVendidas2.png": "0d83000c30c7e0dd3c13f3dabfff2c7a",
"assets/assets/imagesTermos/debito1.png": "3765deaf9ed3237d29062cbb39007e41",
"assets/assets/imagesTermos/debito2.png": "c5d5a3be8c5e47b373cee5297166baca",
"assets/assets/imagesTermos/demonstracaoContabil1.png": "65848c76e63fbaa05fd840d7824d4a38",
"assets/assets/imagesTermos/demonstracaoContabil2.png": "70e8b0e49d21e8fa77b680b0c4740e7e",
"assets/assets/imagesTermos/demonstracaoResultado1.png": "48285eb23430f90737fa056512f32ef9",
"assets/assets/imagesTermos/demonstracaoResultado2.png": "94ede6ba4d526d5f172f073578cf28a7",
"assets/assets/imagesTermos/depositoBancario1.png": "5c45540b48009905cf1a1975e0b6bc90",
"assets/assets/imagesTermos/depositobancario2.png": "adb1de54726c0de3075c513d6004403e",
"assets/assets/imagesTermos/depreciacao1.png": "9b2037e8323ccd566cc5eea5b9c5c6dd",
"assets/assets/imagesTermos/depreciacao2.png": "19b4256737e427d9c69c504081500e47",
"assets/assets/imagesTermos/despesa1.png": "1dfc3b6655aa1f17f2d874984ee47f57",
"assets/assets/imagesTermos/despesa2.png": "9ba3a9b2c7cecb113f542ec1b8b720a1",
"assets/assets/imagesTermos/direito1.png": "813071a4f3f618473b334fed858deb0d",
"assets/assets/imagesTermos/direito2.png": "6c93198ef7d99d7b19c9965170585708",
"assets/assets/imagesTermos/emprestimo1.png": "8894078ff6c41a3a00432eecc0f25c77",
"assets/assets/imagesTermos/emprestimo2.png": "c896b019a3b324453e6894e3a8e672c0",
"assets/assets/imagesTermos/estoque1.png": "b12678065154da7d9e2041cc91cb8b74",
"assets/assets/imagesTermos/estoque2.png": "22a185e87f639cef931e3340348642ed",
"assets/assets/imagesTermos/fatoContabil1.png": "69e52202fcde9b95b3f207fb9beb4fc4",
"assets/assets/imagesTermos/fatoContabil2.png": "262bbb17779d7aaecda21a88ec4be99d",
"assets/assets/imagesTermos/fgts1.png": "6508aa770a37dafefa45714c1bf25588",
"assets/assets/imagesTermos/fgts2.png": "27e146c629f223269bf2f9d751dc8827",
"assets/assets/imagesTermos/fornecedor1.png": "7bfa61c3f76ed51dca31b199bcda5fb7",
"assets/assets/imagesTermos/fornecedor2.png": "a15b2d69fa84bf09ceece17a498c0ee7",
"assets/assets/imagesTermos/icms1.png": "652a3f3d7d68e480e08b98994621e9bb",
"assets/assets/imagesTermos/icms2.png": "6654d8a7cc11bf02c2af0ce4186e0eba",
"assets/assets/imagesTermos/imobilizado1.png": "e98752e83b9d36b5ad0828ee7e59e35e",
"assets/assets/imagesTermos/imobilizado2.png": "211edd9e2c07c377095e1b2a3efbe8fd",
"assets/assets/imagesTermos/imposto1.png": "b0881286ab0035e2f3e607d22a21d366",
"assets/assets/imagesTermos/imposto2.png": "93d19d12ea287ccc7ce4888ff42577cd",
"assets/assets/imagesTermos/impostoDeRenda1.png": "e6996e34b43603ca6c5ed2b893e7d9a0",
"assets/assets/imagesTermos/impostoDeRenda2.png": "4e0a89cebf3df26060d2291e0a832095",
"assets/assets/imagesTermos/inss1.png": "0f9aca086d836f4bd5b4c595e9e1363b",
"assets/assets/imagesTermos/inss2.png": "856b299e6ac7a5cbf19a33b920f0c6b9",
"assets/assets/imagesTermos/integralizacaoDeCapital1.png": "0642cc25b67448ed6f638ac900841e3a",
"assets/assets/imagesTermos/integralizacaoDeCapital2.png": "f729b1a97bfdbaec7a07d2c3d55167fc",
"assets/assets/imagesTermos/investimento1.png": "16e6c10abc72915028b4c4eec59753ac",
"assets/assets/imagesTermos/investimento2.png": "0e063d032dd4922ce697729247210f3c",
"assets/assets/imagesTermos/lucro1.png": "ea6aafbee37a42a068f7f0650ec6cd0e",
"assets/assets/imagesTermos/lucro2.png": "ecf1aa1e26324f223f4695efd6b5c27c",
"assets/assets/imagesTermos/maquinaeequipamentos1.png": "23e7925a2eecfd5fba2975804d024a66",
"assets/assets/imagesTermos/maquinaeequipamentos2.png": "6ab7cf84ca32ada9dabbf76da8b609eb",
"assets/assets/imagesTermos/materiaprima1.png": "850802b33ccb95e7425cce39c4370d92",
"assets/assets/imagesTermos/materiaprima2.png": "8e9847ef87c9eb30049b792c43a43c59",
"assets/assets/imagesTermos/mercadoria1.png": "b2d0bcaa62386a8f0c9ef74a4c4c4f16",
"assets/assets/imagesTermos/mercadoria2.png": "2b65582501e373467e75b8237aefb7de",
"assets/assets/imagesTermos/normas1.png": "1d9486b2b819e5e772d7bd92d0383aaf",
"assets/assets/imagesTermos/normas2.png": "26411b725cfd38c467d673ed4a6894c9",
"assets/assets/imagesTermos/obrigacoes1.png": "0e57c13574793deb23a4afab08fc880f",
"assets/assets/imagesTermos/obrigacoes2.png": "9fa1900894d255cb712848cc108af367",
"assets/assets/imagesTermos/passivo1.png": "c4e6aa216e7c808fe70930ce23761508",
"assets/assets/imagesTermos/passivo2.png": "c4155fa3139153b508c81483f2919ed2",
"assets/assets/imagesTermos/patrimonioliquido1.png": "6e49c7045d4f7d0c3aa1680f093bce06",
"assets/assets/imagesTermos/patrimonioliquido2.png": "d3e6de9f672704e2295d49dc8ffd5048",
"assets/assets/imagesTermos/precodevenda1.png": "43e1757831585625e05acea004be0dfa",
"assets/assets/imagesTermos/precodevenda2.png": "5d12f3e922cef1965ccfc1dd45008d5a",
"assets/assets/imagesTermos/prejuizo1.png": "e7c8544862e8e8973ce3862f75892f5a",
"assets/assets/imagesTermos/prejuizo2.png": "b63792fb3eac164c81b0c5780cad6031",
"assets/assets/imagesTermos/receitaoufaturamento1.png": "359146c5b1144c91301fad9a219c0f93",
"assets/assets/imagesTermos/receitaoufaturamento2.png": "c1d1f944ba561448c983d715081a829b",
"assets/assets/imagesTermos/salarios1.png": "a2f22fc293fd68092ab790109496d95f",
"assets/assets/imagesTermos/salarios2.png": "e9fe74d7ddf2d7649cf4c0b48f171ed5",
"assets/assets/imagesTermos/veiculo1.png": "89e79c5aa39ef7eaa45c1b548cabf200",
"assets/assets/imagesTermos/veiculo2.png": "f63c945ccdee797c97aee15c1213294e",
"assets/assets/imagesTermos/venda1.png": "822418a7947abe9aed77514f9e7d5898",
"assets/assets/imagesTermos/venda2.png": "7255309cd885bf896e1b9e88fbf89f02",
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
"favicon.png": "95828833ffdab84ec2a44e2427ebc401",
"flutter.js": "c71a09214cb6f5f8996a531350400a9a",
"icons/Icon-192.png": "3721c0c1bc551f3a08acfc62336e59b4",
"icons/Icon-512.png": "e722a9faf298191502e43e91562806ea",
"icons/Icon-maskable-192.png": "3721c0c1bc551f3a08acfc62336e59b4",
"icons/Icon-maskable-512.png": "e722a9faf298191502e43e91562806ea",
"index.html": "89e142f5ba4e846541b596314ba35de2",
"/": "89e142f5ba4e846541b596314ba35de2",
"main.dart.js": "6fb7a4f8a273b7ab6194b3e7b4c76064",
"manifest.json": "11880fb1a59b88afe7d07c7313f685ae",
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

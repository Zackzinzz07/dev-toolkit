# Análise técnica: fojcikdominik.com

> Feita por um agente do `claude-work` (Sonnet, effort high) em 19/11/2026, lendo só arquivos públicos do site, sem executar nada. Os trechos de código são esqueletos originais, não cópia do site. Inferências e itens não confirmados estão marcados.

**Resumo:** o site é uma cena 3D em Three.js (WebGPU, com WebGL de reserva) dentro de uma página Astro. O scroll vira um número de 0 a 1 que move a câmera. O texto é HTML real por cima do canvas.

**Aviso sobre a coleta:** não consegui criar `./baixado`, porque a escrita ali pedia aprovação e a sessão não é interativa. Salvei os arquivos na pasta de rascunho da sessão: `/tmp/claude-1000/-home-salati-agy-grafo-portfolio-analise/b22b6f96-9d44-4f1e-9651-4af4e7f084ac/scratchpad/baixado/`.

- **Baixados:** 24 arquivos (HTML, 22 JS e 1 JSON), todos abaixo de 3 MB. Nada foi executado, só lido como texto.
- **Lidos por inteiro:**
  - `layout.astro_astro_type_script_index_2_lang.Bus_C_Mv.js`, que chamo de "bundle principal" (Lenis, Anime.js, lógica de scroll, rotas e preloader);
  - `render-app.B5TwDRxr.js`;
  - os módulos pequenos (`runtime`, `stores`, `store`, `route`, `page`, `preloader`, `render-path`, `page-scene`, etc.).
- **Lidos só em parte:** `scene.js` (cerca de 30% do arquivo) e o início do `pipeline-manifest.json`.
- **Não lidos:** o worker de render (972 KB), `three.js` (914 KB), `splat-scan`, `screen.js`, os shaders de CRT/camcorder e o corpo do CSS.

## 1. Stack

| Item | O que vi | Fonte |
|---|---|---|
| Framework | **Astro v6.4.8** com View Transitions (`ClientRouter`) | `<meta name="generator" content="Astro v6.4.8">` e `astro-view-transitions-enabled` no `index.html` |
| Hospedagem | **Cloudflare** (confirmado). Cloudflare Pages é inferência, pela lista de hosts que inclui `portfolio-171.pages.dev` | header `server: cloudflare`; `layout.astro_..._index_1_lang` |
| CSS | **Tailwind v4**: estrutura `@layer properties/theme/base/components/utilities` e `calc(var(--spacing) * N)`. A versão exata não foi confirmada | CSS inline do `index.html` |
| Fontes | OffBit DotBold e Doto (400 a 900), woff2 do próprio site, `font-display: swap`, com preload de duas delas | `@font-face` no `index.html` |
| 3D | **Three.js r187** com `WebGPURenderer` e nós TSL, e `forceWebGL` como reserva | `pipeline-manifest.json` ("Three.js r187 – Node System"); `render-app.B5TwDRxr.js` |
| Scroll suave | **Lenis 1.3.26**, com Lenis Snap | bundle principal (`_i="1.3.26"`, classe `Cr` de snap) |
| Animação | **Anime.js 4.5.0**, estendido por adaptadores para animar objetos e uniforms do Three | bundle principal (`version:"4.5.0"`) e `render-app.B5TwDRxr.js` |
| Estado | cópia embutida do padrão nanostores (`globalThis.nanostoresGlobal`) | `store.js` |
| Analytics | PostHog sem cookies (host EU, sem autocapture), carregado depois do `load` e do idle, e não em localhost. Há também o beacon do Cloudflare Web Analytics | bundle principal; `data-cf-beacon` |
| CMS | **Nenhum visto.** Os 4 projetos estão num array fixo no código (`id`, `images`, `model`); os textos estão no HTML | bundle principal (`ae=[...]`) |

Os ativos 3D usam GLTF com Draco e Meshopt, texturas KTX2 (`/basis/`) e HDR. Também vi formatos próprios: `/glitch-portrait.af` e `/splats/about.vsplat` (nuvem de pontos gaussiana). As imagens dos projetos são `.avif`.

## 2. Animação

- **Scroll → cena:** a página tem um container `[data-page-scroll]` com um espaçador `[data-scroll-length]`. O Lenis roda ali (`lerp .08`, `touchMultiplier 1.5`, `autoRaf:false`, `respectReducedMotion:true`) e alimenta um store com `scrollProgress` (0 a 1). Esse número vira "viewports" (`At.viewports`), que viram a rotação e a posição da câmera na cena. Fonte: classe `kr` e objeto `At` no bundle principal.
- **Snap:** o Lenis Snap em modo `proximity`, com paradas em cada projeto. Fica desligado no celular, dentro de um projeto e em trechos da cena.
- **Celular:** o scroll é nativo e o `scrollProgress` é suavizado com amortecimento próprio (`smoothTouch`, 0,07 s).
- **Transições de página:** `ClientRouter` do Astro, mais um `[data-page-fade]`. O código segura a troca de DOM até o fade terminar (`holdSwapForFade`). A home guarda seu DOM em `<template data-home-view>` quando você está numa página interna.
- **Rotas dentro da cena:** a URL muda para `/triar`, `/catalogue` etc. via `history.pushState` conforme o scroll. Fonte: `Wo` e `qo` no bundle principal.
- **Preloader:** um store com `progress`, `isReady`, `isWarm` e `isGateOpen`. O progresso vem do `LoadingManager` do Three. Depois entra uma fila de pré-compilação de materiais (`compileAsync`). A porta abre quando tudo está pronto, ou após 20 s (`preloader.astro_..._index_0_lang`).
- **Cursor customizado:** não confirmado. Existe `data-vibe-cursor` no HTML, mas não segui isso no código.
- **Texto:** `[data-scramble-text]` embaralha caracteres no hover e na entrada. Dura 700 ms com `out(3)`, usa o utilitário de scramble do Anime e é desligado com reduced motion.
- **Pós-processamento:** os "layers" do store são fisheye, camcorder, tape blur/noise/line, CRT e glass (`stores.js`). Só o fisheye foi lido com detalhe (força 0,1 no desktop e 0,2 no celular). O TRAA (suavização temporal) está no código, mas vem desligado.
- **Parallax e tilt:** matrizes `matrix3d` calculadas no 3D e aplicadas a elementos HTML. No celular, o `deviceorientation` gera tilt, com tela de permissão no iOS (`$r`/`Wr` no bundle principal).

## 3. Efeitos marcantes e como reproduzir

1. **Rótulos HTML presos a objetos 3D (seção "Selected work").** Cada título é um `<li>` real. A cada frame, a cena projeta os 4 cantos do plano 3D na tela, resolve a matriz que leva um retângulo ao quadrilátero (homografia) e escreve `matrix3d(...)` no estilo do `<li>`. Quando o plano está de costas ou fora da tela, o item recebe `data-hidden` e `inert`. Resultado: texto selecionável e acessível, colado em geometria 3D. Fonte: `qu`/`Bu` em `scene.js`, `$o` no bundle principal. Versão simples: `Vector3.project()` e `translate3d`.
2. **Mouse correto sob a lente fisheye.** A distorção deforma a imagem, então o ponteiro é "des-distorcido" antes do raycast (12 iterações para inverter a fórmula). Assim o hover acerta o objeto certo. Fonte: `ts`/`Gs` em `render-app.B5TwDRxr.js`.
3. **Vídeo "escrubado" por WebCodecs.** Um arquivo com manifesto de frames (chaves e deltas) é decodificado com `VideoDecoder` (hvc1 ou avc1). O frame desejado vira textura. Há um mapa de quadtree em cima. Fonte: classe `dd` em `scene.js`. Não confirmei qual arquivo ou parte da cena usa isso.
4. **Scramble no hover.** Descrito na seção 2.
5. **Página `/about` com splat gaussiano.** A câmera desce `2,45` "viewports" por viewport rolado, com `damp` de 6, mais vinheta e contraste num shader TSL. Fonte: `page-scene.js`.

## 4. Desempenho e acessibilidade

**Desempenho** (tudo visto no código):
- **Render fora da thread principal:** em Chromium, o canvas vai para um `OffscreenCanvas` num Worker, e os ponteiros são repassados por `MessageChannel`. Safari e Firefox rodam na thread principal (`user-agent.js`, `render-path.js`).
- **Três níveis de render:** WebGPU, depois WebGL, depois nada. No nível "nada", redireciona para `bio.fojcikdominik.com`, uma versão simples. O nível fica em `sessionStorage` (`layout1.js`).
- **Pré-aquecimento de shaders:** `pipeline-manifest.json` tem 743 KB com `requestDevice` e módulos de shader. Três workers (`warm-pipelines.worker`) o recebem quando o nível é WebGPU (`layout0.js`). Que eles compilam pipelines de antemão é minha inferência, pois não li o worker.
- **Resolução adaptativa** (`ys` em `render-app.B5TwDRxr.js`):
  - mede FPS em janelas de 1 s;
  - abaixo de 25 fps, reduz a escala em 0,25;
  - acima de 50, recupera;
  - em iPhone, pode subir até 2x acima de 55 fps.
  - Existem dois perfis ("high" e "medium"). O "medium" vale para iPhones de tela pequena, até 4 GB de RAM ou adaptador limitado.
- **Contrapressão da GPU:** não enfileira frame se já há 2 não concluídos (`onSubmittedWorkDone`).
- **Delta limitado:** o tempo por frame é cortado em 50 ms.
- **Pausa e liberação:** pausa fora da tela (`IntersectionObserver`) e com a aba oculta. Quando a aba está oculta, destrói o renderer e recria ao voltar. Recupera perda de dispositivo e erro de chunk, recarregando no máximo uma vez a cada 5 min.
- **Memória:** texturas viram `ImageBitmap` e o bitmap é fechado após o upload.
- **Mídia:** 19 `<img loading="lazy">` no HTML.
- **Cache dos assets:** `cache-control: public, max-age=31536000, immutable`. O HTML usa `max-age=0, must-revalidate`.

**Acessibilidade:**
- **Reduced motion:** `prefers-reduced-motion` é lido e guardado num store (`isReducedMotion`). Desliga scramble, tilt e o scroll animado. O Lenis também respeita. O CSS tem utilitários `motion-reduce:*` e `[data-menu-backdrop]{transition:none}`. **Não confirmado:** se a cena 3D vira estática; o movimento continua dirigido pelo scroll.
- **Semântica e foco:** `h1`, `h2` e `h3` semânticos, `aria-label` nos projetos e imagens, `aria-current`, `inert` em painéis inativos, setas e Esc nos slides, e a classe `is-tabbing` para foco por teclado.

## 5. Estrutura do código

- Páginas Astro (`/`, `/about`, `/contact`, `/articles`, `/tools`, `/credits`, `/privacy`), cada uma com scripts por componente: `layout`, `header`, `preloader`, `ClientRouter`.
- Núcleo em módulos pequenos de estado: `page`, `route`, `preloader`, `runtime` e `postLayers`. Eles são espelhados para o worker por `MessageChannel` (`stores.js`, `runtime.js`).
- Cenas separadas e carregadas sob demanda: `scene.js` (home) e `page-scene.js` (páginas internas).
- Dados dos projetos: array no código, não JSON nem CMS.
- Textos e títulos no HTML renderizado pelo servidor, com `<noscript>` não encontrado.

## 6. Esqueleto original dos 3 efeitos que mais valem aprender

**A. Scroll virtual → progresso amortecido → cena**
```html
<div id="scroller" style="height:100svh;overflow:auto"><div style="height:600svh"></div></div>
<canvas id="stage" style="position:fixed;inset:0;pointer-events:none"></canvas>
```
```js
import Lenis from 'lenis';
const scroller = document.querySelector('#scroller');
const lenis = new Lenis({ wrapper: scroller, content: scroller.firstElementChild, lerp: 0.08, autoRaf: false });
const s = { target: 0, smooth: 0 };
lenis.on('scroll', ({ progress }) => (s.target = progress));
const damp = (a, b, k, dt) => a + (b - a) * (1 - Math.exp(-k * dt));
let last = performance.now();
(function frame(t) {
  const dt = Math.min((t - last) / 1000, 0.05); last = t;
  lenis.raf(t);
  s.smooth = damp(s.smooth, s.target, 8, dt);
  draw(s.smooth);               // sua função: câmera, opacidades, etc.
  requestAnimationFrame(frame);
})(last);
```

**B. Texto que "decodifica" no hover (acessível)**
```js
const GLYPHS = '▒░#%/*+=_';
function scramble(el, ms = 600) {
  if (matchMedia('(prefers-reduced-motion: reduce)').matches) return;
  const final = (el.dataset.final ??= el.textContent);
  el.setAttribute('aria-label', final);          // leitor de tela não lê o lixo
  cancelAnimationFrame(el._raf);
  const t0 = performance.now();
  const tick = (now) => {
    const p = Math.min((now - t0) / ms, 1), n = Math.floor(p * final.length);
    el.textContent = [...final].map((c, i) =>
      i < n || c === ' ' ? c : GLYPHS[(Math.random() * GLYPHS.length) | 0]).join('');
    p < 1 ? (el._raf = requestAnimationFrame(tick)) : (el.textContent = final);
  };
  el._raf = requestAnimationFrame(tick);
}
document.addEventListener('pointerover', e => {
  const el = e.target.closest('[data-scramble]'); if (el) scramble(el);
});
```

**C. Qualidade adaptativa + pausa fora da tela (para qualquer canvas)**
```js
let frames = 0, acc = 0, scale = Math.min(devicePixelRatio, 1.5), running = true;
new IntersectionObserver(([e]) => (running = e.isIntersecting && !document.hidden)).observe(canvas);
document.addEventListener('visibilitychange', () => (running = !document.hidden));
function adapt(dt) {
  frames++; acc += dt;
  if (acc < 1) return;
  const fps = frames / acc; frames = 0; acc = 0;
  if (fps < 28) scale = Math.max(0.75, scale - 0.25);
  else if (fps > 54) scale = Math.min(Math.min(devicePixelRatio, 2), scale + 0.25);
  renderer.setPixelRatio(scale);
}
// no loop: if (!running) return; adapt(dt); render();
```

## 7. Comparação com a skill scroll-craft

A leitura veio de um agente que abriu o README, o `SKILL.md`, `references/devices.md` e `references/verify.md` (v0.3.0, MIT). Ele **não leu** `worldflight.md`, `taste.md`, `feel.md`, `hero-depth.md` e outros. A comparação vale só para o que foi lido.

| O que o site faz | scroll-craft cobre? |
|---|---|
| Frames de vídeo ligados ao scroll | **Sim** (`scrub`, §1), mas com `<video>` e GOP denso; o site usa WebCodecs |
| Cena fixa com texto avançando | **Sim** (`pin`, §2; e "worldflight", não lido) |
| Revelação por `clip-path` | **Sim** (`reveal`, §4) |
| Texto cinético | **Parcial** (`kinetic`, §5, monta por linha, palavra ou caractere; sem o scramble) |
| Parallax | **Sim** (§6), em camadas DOM |
| Tilt e efeitos de ponteiro | **Parcial** (§9, só ponteiro; o site também usa giroscópio) |
| `prefers-reduced-motion` | **Sim**, com regras explícitas (clipes não baixam, lerp 1, parallax zerado) |
| Three.js, WebGPU, worker, shaders, pós-processamento | **Não** |
| Splat gaussiano, rótulos HTML projetados do 3D | **Não** |
| Transição entre páginas, rotas ligadas à cena | **Não** (foco em landing única) |
| Pré-aquecimento de shaders, resolução adaptativa, recuperação de GPU | **Não** (o README diz que não traz metas numéricas de desempenho) |

A skill só gera sites estáticos de scroll com engine próprio, sem WebGL.

## 8. Aplicação ao catálogo de joias (foto grande, zoom, filtro, WhatsApp)

Recomendações minhas, não do site analisado.

- **Não use WebGL no catálogo.** Foto grande bem comprimida costuma ser mais nítida e mais leve que uma cena 3D, e o site só se sustenta porque tem várias camadas de contenção. Se quiser uma cena, faça só no topo, com uma imagem estática de reserva.
- **Imagens:** AVIF com WebP de reserva, `srcset` e `sizes`, `loading="lazy"` e `decoding="async"`. A primeira foto da página vai com `fetchpriority="high"`. Miniaturas pequenas na grade e a versão grande só quando abrir.
- **Zoom:** ao tocar, abra um `<dialog>` e só então baixe a foto de alta resolução. Faça pan e zoom com `transform` e `pointer events`, sem biblioteca. Para um giro 360 da peça, use 24 a 36 frames trocados conforme o toque ou o scroll (mesma ideia do `scrub`), em vez de modelo 3D.
- **Filtro:** filtre no cliente, via atributos `data-categoria` e `data-metal`, e anime a reordenação com FLIP ou a View Transitions API. Atualize a URL com `?cat=aneis` para links compartilháveis.
- **WhatsApp:** `https://wa.me/55NUMERO?text=` + `encodeURIComponent("Olá! Tenho interesse em: Anel X (ref 123) — link da peça")`. Peça-me o número e o texto padrão antes de fechar.
- **Celular:**
  - use scroll nativo, sem Lenis, ou use o Lenis só no desktop (o próprio site faz scroll nativo no celular);
  - aplique `content-visibility:auto` nas seções longas;
  - respeite `prefers-reduced-motion`;
  - evite o efeito scramble em texto de preço ou referência.
- **Stack:** Astro estático na Cloudflare Pages, com ilhas JS só no zoom e no filtro, e cache `immutable` nos assets com hash.

## Não confirmado

- Versão exata do Tailwind v4 e se a hospedagem é Cloudflare Pages ou outro produto Cloudflare.
- Cursor customizado (`data-vibe-cursor` existe, mas não foi investigado).
- Conteúdo dos workers `warm-pipelines` e `render-app-BuNcj5sy.js`; o que `screen.js` faz ao apresentar frames.
- Shaders de CRT, camcorder, tape e glass, e qual arquivo de vídeo usa o decodificador WebCodecs.
- Se a cena 3D fica estática com `prefers-reduced-motion`.
- Conteúdo das páginas internas (`/articles`, `/tools`, `/about` em detalhe) e se `<noscript>` existe.
- Metas de desempenho reais (LCP, peso total), pois não rodei Lighthouse.
- Do scroll-craft: `worldflight.md` e as demais referências não lidas.
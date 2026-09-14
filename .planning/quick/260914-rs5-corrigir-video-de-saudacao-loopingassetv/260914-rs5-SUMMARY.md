---
phase: 260914-rs5-corrigir-video-de-saudacao-loopingassetv
plan: 1
subsystem: ui
tags: [flutter, video_player, webview, whatsapp, fallback]

# Dependency graph
requires: []
provides:
  - "LoopingAssetVideo com controles web do <video> desabilitados (VideoPlayerWebOptions)"
  - "Fallback automático para imagem estática (acenando-removebg-preview.png) em timeout/erro de playback"
affects: [home_screen (consumidor único, não modificado)]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Confirmação de playback via listener + isPlaying antes de exibir widget de vídeo, com timeout de fallback estático"

key-files:
  created: []
  modified:
    - conta_libras_2/lib/ui/widgets/looping_asset_video.dart

key-decisions:
  - "Fallback fica permanente para a instância do widget (sem retentativa) uma vez ativado, conforme plano"
  - "catchError() dos Futures de initialize()/play() usa blocos { } em vez de arrow function, para satisfazer o tipo FutureOr<Null> exigido pelo Dart (flutter analyze acusava invalid_return_type_for_catch_error com a forma em arrow)"

patterns-established:
  - "Widgets de vídeo web-embarcado devem confirmar isPlaying antes de renderizar o <video>, com timeout + fallback estático para evitar controles nativos quebrados em WebViews restritas (WhatsApp/Instagram in-app browser)"

requirements-completed: [BUGFIX-RS5]

# Metrics
duration: 12min
completed: 2026-09-14
---

# Quick Task 260914-rs5: Corrigir vídeo de saudação quebrado no WebView do WhatsApp Summary

**LoopingAssetVideo agora desabilita controles nativos de vídeo no web e cai para imagem estática de fallback quando o playback não é confirmado em 3s ou o controller reporta erro.**

## Performance

- **Duration:** 12 min
- **Started:** 2026-09-14T22:56:00Z (aprox.)
- **Completed:** 2026-09-14T23:08:21Z
- **Tasks:** 1 de 2 (Task 2 é checkpoint humano manual, ver abaixo)
- **Files modified:** 1

## Accomplishments
- `VideoPlayerWebOptions` com `controls: VideoPlayerWebOptionsControls.disabled()`, `allowContextMenu: false` e `allowRemotePlayback: false` configurados explicitamente no `VideoPlayerController.asset`, evitando que o navegador caia para controles nativos sobrepostos ao texto.
- Vídeo só é renderizado após o controller confirmar `isPlaying == true`; antes disso (ou em caso de timeout/erro) a imagem estática `assets/images/acenando-removebg-preview.png` é exibida no mesmo tamanho/borda, sem pulo de layout e sem "flash" em branco.
- Timeout de 3s (`Timer`) e listener de erro (`hasError`) ativam o mesmo fallback (`_activateFallback`), que é idempotente e permanente para a instância do widget.
- `dispose()` cancela o timer e remove o listener antes de descartar o controller, evitando leaks/callbacks pós-unmount.

## Task Commits

Each task was committed atomically:

1. **Task 1: Corrigir LoopingAssetVideo com fallback estático e controles web bloqueados** - `34251b2` (fix)
2. **Task 2: Verificar visualmente o fix em Chrome e no navegador embutido do WhatsApp/Android** - **NÃO EXECUTADO** (checkpoint humano, ver seção "Etapa Manual Pendente" abaixo)

**Plan metadata:** commit de docs feito separadamente pelo orquestrador.

## Files Created/Modified
- `conta_libras_2/lib/ui/widgets/looping_asset_video.dart` - Widget de vídeo de saudação reescrito com controles web bloqueados, confirmação de playback e fallback estático permanente.

## Decisions Made
- Mantido o default `fallbackAssetImage = 'assets/images/acenando-removebg-preview.png'` para preservar o call site existente em `home_screen.dart` (não modificado, conforme escopo do plano).
- `catchError` reescrito com bloco `{ }` (em vez de arrow function) nas duas ocorrências (`initialize()` e `play()`) para satisfazer o tipo `FutureOr<Null>` exigido pelo analisador Dart — sem essa mudança `flutter analyze` reportava `invalid_return_type_for_catch_error`. Comportamento idêntico ao especificado no plano, apenas ajuste de sintaxe para compilar limpo.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Correção de sintaxe em catchError para satisfazer flutter analyze**
- **Found during:** Task 1 (verificação `flutter analyze`)
- **Issue:** `.catchError((_) => _activateFallback())` gerava warning `invalid_return_type_for_catch_error` porque `_activateFallback()` retorna `void` e `catchError` espera `FutureOr<Null>`.
- **Fix:** Trocado para `.catchError((_) { _activateFallback(); })` nas duas ocorrências (dentro do `.then()` para `play()` e no `.initialize()`).
- **Files modified:** conta_libras_2/lib/ui/widgets/looping_asset_video.dart
- **Verification:** `flutter analyze` retornou "No issues found!"
- **Committed in:** `34251b2` (parte do commit da Task 1)

---

**Total deviations:** 1 auto-fixed (1 bug de sintaxe/tipagem)
**Impact on plan:** Ajuste puramente sintático para atender ao linter; comportamento funcional idêntico ao especificado no plano. Sem scope creep.

## Issues Encountered
None além do item de deviation acima.

## Etapa Manual Pendente (Task 2 — checkpoint:human-verify)

Task 2 do plano é um checkpoint de verificação humana e **não foi executado por este agente** — requer ambiente visual (Chrome + navegador embutido do WhatsApp/Android) e deploy, que não podem ser automatizados neste contexto.

**Passos que o usuário precisa seguir depois do deploy:**
1. Rodar `cd conta_libras_2 && flutter run -d chrome`, abrir a home e confirmar que o vídeo de saudação ao lado de "Olá, [nome]!" continua mudo, em loop e com autoplay — sem regressão no caminho de sucesso.
2. Fazer o deploy da alteração (fluxo já usado pelo projeto para a-libras.vercel.app).
3. No celular Android, abrir a URL do app através do navegador embutido do WhatsApp (compartilhar o link numa conversa e abrir por lá) e confirmar que:
   - Não aparecem controles nativos de vídeo (play/pause, timestamp, PiP) sobrepostos ao texto.
   - Ou o vídeo funciona normalmente em loop, ou a imagem estática de "acenando" aparece no lugar — sem sobreposição quebrada e sem pulo de layout.
   - Ao navegar entre outras telas dentro dessa WebView, nada fica "travado/fixo" sobre o conteúdo novo.

Só marcar esta quick task como totalmente concluída após essa verificação manual.

## User Setup Required
None - nenhuma configuração de serviço externo necessária. A verificação visual pós-deploy (acima) é o único passo pendente do usuário.

## Next Phase Readiness
- Código pronto e commitado (`34251b2`); `flutter analyze` limpo.
- `home_screen.dart`, `term_detail_screen.dart` e `pubspec.yaml` permanecem intocados, conforme escopo.
- Bloqueador: confirmação visual em Chrome e na WebView do WhatsApp/Android após deploy (Task 2) ainda pendente do usuário.

---
*Phase: 260914-rs5-corrigir-video-de-saudacao-loopingassetv*
*Completed: 2026-09-14*

## Self-Check: PASSED

- FOUND: conta_libras_2/lib/ui/widgets/looping_asset_video.dart
- FOUND: commit 34251b2 (git log --oneline --all)

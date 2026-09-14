---
phase: 260914-s0w-corrigir-persistencia-de-progresso-de-te
plan: 1
subsystem: ui
tags: [flutter, shared_preferences, dicionario, progresso]

provides:
  - "ProgressManager persiste termos vistos em shared_preferences, isolado por perfil local (userId)"
  - "Dois estados visuais distintos no Dicionario: cinza transitorio (sessao atual) vs badge de check persistido (sessoes anteriores)"

tech-stack:
  added: []
  patterns:
    - "Persistencia local via shared_preferences seguindo o padrao ja estabelecido em ProfileStorageService (timeout de 4s, try/catch com debugPrint, chaves com prefixo contalibras_)"

key-files:
  created: []
  modified:
    - conta_libras_2/lib/data/managers/progress_manager.dart
    - conta_libras_2/lib/ui/screens/splash/splash_screen.dart
    - conta_libras_2/lib/ui/screens/profile_selection/profile_selection_screen.dart
    - conta_libras_2/lib/ui/screens/first_access/first_access_screen.dart
    - conta_libras_2/lib/ui/screens/profile/profile_screen.dart
    - conta_libras_2/lib/ui/widgets/term_card.dart
    - conta_libras_2/lib/ui/screens/dictionary/dictionary_screen.dart

key-decisions:
  - "Cinza permanece exclusivamente o indicador transitorio de _recentlyViewedTermIds em MainScreen (nao alterado); um badge de check separado, alimentado por ProgressManager persistido, indica 'visitado em sessao anterior'"
  - "Chave de persistencia usa UserProfile.id (perfil local), nao cadastroId (que e opcional e depende do backend Supabase)"
  - "loadForUser() sempre limpa o Set em memoria antes de carregar, para trocas de perfil sem reiniciar o app nunca herdarem progresso do perfil anterior"

patterns-established:
  - "Progresso local por usuario: chave shared_preferences contalibras_viewed_terms_<userId>, carregado nos 4 pontos de entrada (splash auto-login, selecao de perfil, cadastro novo) e limpo no logout"

requirements-completed: [BUGFIX-S0W]

duration: ~10min (2 tasks automaticos)
completed: 2026-09-14
---

# Quick Task 260914-s0w: Persistência do progresso do Dicionário — Summary

**Progresso de "Termos Explorados" e marcação de termos já vistos no Dicionário agora sobrevivem a fechar/reabrir o app, com dois estados visuais distintos (cinza transitório vs. badge persistido).**

## Performance

- **Tasks:** 2 de 3 completados automaticamente (Task 3 é checkpoint de verificação manual humana, não executável neste ambiente — sem browser/`flutter run`/deploy disponíveis)
- **Files modified:** 7

## Accomplishments
- `ProgressManager` deixou de guardar termos vistos apenas em memória: agora persiste em `shared_preferences` sob a chave `contalibras_viewed_terms_<userId>`, isolado por perfil local.
- Os 4 pontos de entrada de usuário (auto-login na splash, seleção de perfil, cadastro novo, logout) foram conectados a `loadForUser`/`clear`, garantindo que o progresso certo carregue antes de `MainScreen` aparecer e que trocar de perfil nunca misture progresso entre usuários.
- `TermCard` ganhou um segundo estado visual (`isPreviouslyViewed`, badge de check) distinto do cinza transitório já existente (`isRecentlyViewed`), conforme requisito refinado pelo dono do projeto: cinza = "em uso agora, nesta visita à tela"; badge = "visitado em sessão anterior, persistido".
- `DictionaryScreen` passou a ouvir `ProgressManager()` via `AnimatedBuilder` para exibir o badge persistido em tempo real.

## Task Commits

Each automatic task was committed atomically (no docs) na branch de trabalho, depois mesclados de volta em `main`:

1. **Task 1: Persistir progresso de termos explorados por perfil local (ProgressManager + shared_preferences)** - `9ad0d90`
2. **Task 2: Dois estados visuais no Dicionário — cinza transitório vs. badge persistido** - `29cfc47`

Merge de volta em `main`: `chore: merge quick task worktree (worktree-agent-a47d53a620cfa33ce)`

## Files Created/Modified
- `conta_libras_2/lib/data/managers/progress_manager.dart` - Adiciona `loadForUser()`, `clear()`, `isViewed()`, `viewedTermIds` e persistência em `shared_preferences` via `_persist()`; `markAsViewed()` agora dispara persistência best-effort.
- `conta_libras_2/lib/ui/screens/splash/splash_screen.dart` - Chama `ProgressManager().loadForUser(match.first.id)` no caminho de auto-login, antes de navegar para `MainScreen`.
- `conta_libras_2/lib/ui/screens/profile_selection/profile_selection_screen.dart` - Chama `loadForUser(profile.id)` em `_selectProfile`, antes de navegar.
- `conta_libras_2/lib/ui/screens/first_access/first_access_screen.dart` - Chama `loadForUser(profile.id)` em `_submit` para perfis novos.
- `conta_libras_2/lib/ui/screens/profile/profile_screen.dart` - Chama `ProgressManager().clear()` em `_logout`, ao lado de `UserManager().clear()`.
- `conta_libras_2/lib/ui/widgets/term_card.dart` - Novo parâmetro `isPreviouslyViewed`; renderiza badge de check (`Icons.check_circle_rounded`) num `Stack` sobre o ícone quando `isPreviouslyViewed && !isRecentlyViewed`. Cinza mantém prioridade visual quando ambos são true.
- `conta_libras_2/lib/ui/screens/dictionary/dictionary_screen.dart` - `ListView.builder` envolvido em `AnimatedBuilder(animation: ProgressManager())`; passa `isPreviouslyViewed: ProgressManager().isViewed(term.id)` para cada `TermCard`.

## Deviations from Plan

Dois ajustes triviais (Rule 1 - correção de bug) foram necessários para manter `flutter analyze` sem novos erros/warnings, ambos causados pelas próprias mudanças exigidas pelo plano:
1. `splash_screen.dart` — adicionado um segundo guard `mounted` antes de `Navigator.pushReplacement`, pois o novo `await ProgressManager().loadForUser(...)` introduziu um gap assíncrono extra antes do uso de `context`.
2. `term_card.dart` — adicionado `const` ao novo `Icon` do badge para satisfazer `prefer_const_constructors`.

## Verification

- `cd conta_libras_2 && flutter analyze` rodado após cada task automática — zero novos erros/warnings.
- **Task 3 (checkpoint:human-verify) permanece pendente** — requer verificação manual do usuário com `flutter run -d chrome` e/ou deploy real. Passos exatos:
  1. `cd conta_libras_2 && flutter run -d chrome`, criar/selecionar um perfil, abrir 2-3 termos no Dicionário — confirmar que ficam cinzas enquanto você permanece na aba (comportamento já existente, sem mudança).
  2. Ir para a aba Início e voltar ao Dicionário (sem recarregar a página) — confirmar que os termos acessados NÃO ficam mais cinzas, e sim com o badge de check no ícone; a % de "Termos Explorados" na Home corresponde ao número de termos acessados.
  3. Fazer deploy (`vercel --prod` ou o fluxo já usado pelo projeto) e recarregar a página (F5) ou reabrir o app com o MESMO perfil — confirmar que a % continua a mesma de antes do reload, e que os mesmos termos continuam com o badge de check.
  4. Criar um segundo perfil (ou "Sair" em Perfil → selecionar/criar outro perfil) — confirmar que esse perfil começa com 0% e nenhum termo marcado (progresso do primeiro perfil não vaza).

## Next Steps

- Usuário deve rodar os 4 passos de verificação manual acima (idealmente após o deploy no Vercel) e confirmar que o comportamento está correto.
- Se algo não bater com o esperado, descrever o problema para reabertura da quick task.

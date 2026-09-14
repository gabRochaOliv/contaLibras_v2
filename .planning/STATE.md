# State

## Current
- **Phase:** 2
- **Status:** complete — Milestone 1 concluído (Fase 1 + Fase 2 completas)
- **Last session:** 2026-06-05 — Fase 2 completa: dashboard Streamlit deployado no Railway e verificado no browser

## Milestone 1 — COMPLETO ✅

### Fase 1: Coleta de Feedbacks e API ✅
- 5 planos executados, API FastAPI deployada no Railway
- Flutter app envia feedbacks para o banco Supabase

### Fase 2: Dashboard de Visualização ✅
- `.planning/phases/02-dashboard/02-01-PLAN.md` — Wave 1 (Infra testes) ✅
- `.planning/phases/02-dashboard/02-02-PLAN.md` — Wave 2 (Dados + gráficos) ✅
- `.planning/phases/02-dashboard/02-03-PLAN.md` — Wave 3 (app.py Streamlit) ✅
- `.planning/phases/02-dashboard/02-04-PLAN.md` — Wave 4 (Deploy Railway) ✅

## Infraestrutura
- API: https://contalibrasv2-production.up.railway.app
- Dashboard: Railway (segundo serviço, Root Directory = dashboard/)
- App Flutter: https://conta-libras.vercel.app
- Banco: Supabase projeto `ythfochjtvaopadnuxiq` (sa-east-1)

## Decisions
- Fixtures conftest.py com linha Intérprete (q30/q41) para validar colunas esparsas no pivot JSONB
- test_auth.py usa hmac.compare_digest diretamente (sem Streamlit) para isolamento total dos testes
- LABELS_QUESTOES para q30-q41 usa rótulos genéricos descritivos (questionario_IHC.md só vai até q29)
- fillna(0) ausente no pivot — NaN preservado para perguntas de categoria (comportamento esparso correto)
- fetch_feedbacks() sem parâmetro de filtro — filtro de categoria é responsabilidade de app.py em memória
- Auth gate usa DASHBOARD_PASSWORD env var com fallback "" — senha vazia garante falha de auth (sem bypass)
- to_csv_bytes() com @st.cache_data sem TTL — cache invalida quando df_wide (argumento) muda
- railway.json em vez de Procfile — pattern correto para novos serviços Railway

### Quick Tasks Completed

| # | Description | Date | Commit | Directory |
|---|-------------|------|--------|-----------|
| 260914-rs5 | Corrigir video de saudacao (LoopingAssetVideo) quebrado no navegador embutido do WhatsApp/Android: desabilitar controles nativos e adicionar fallback para imagem estatica | 2026-09-14 | 34251b2 | [260914-rs5-corrigir-video-de-saudacao-loopingassetv](./quick/260914-rs5-corrigir-video-de-saudacao-loopingassetv/) |
| 260914-s0w | Corrigir persistencia de progresso de Termos Explorados e marcacao de termos acessados (cinza) no Dicionario apos sair e voltar ao app | 2026-09-14 | 8e2b6a1 | [260914-s0w-corrigir-persistencia-de-progresso-de-te](./quick/260914-s0w-corrigir-persistencia-de-progresso-de-te/) |

## Resume
- Milestone 1 concluído — sistema de coleta + dashboard operacional
- Próximo: coleta de dados reais com usuários (fase de campo do TCC)
- Pendente: verificação manual do fix do vídeo de saudação (260914-rs5) em Chrome e no WebView do WhatsApp/Android após o próximo deploy
- Pendente: verificação manual do fix de persistência do Dicionário (260914-s0w) apos deploy — ver os 4 passos em .planning/quick/260914-s0w-corrigir-persistencia-de-progresso-de-te/260914-s0w-SUMMARY.md

Last activity: 2026-09-14 - Completed quick task 260914-s0w: Corrigir persistencia de progresso de Termos Explorados e marcacao de termos acessados no Dicionario

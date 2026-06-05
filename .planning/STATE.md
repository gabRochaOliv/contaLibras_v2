# State

## Current
- **Phase:** 2
- **Plan:** 4 (checkpoint ativo — Task 2 aguarda verificação humana)
- **Status:** in-progress — 3/4 planos completos + plano 04 em checkpoint
- **Last session:** 2026-06-05 — Plano 02-04 Task 1 executada (railway.json criado, commit 5680902) — aguardando deploy Railway pelo pesquisador

## Plans — Fase 2 (Dashboard de Visualização)
- `.planning/phases/02-dashboard/02-01-PLAN.md` — Wave 1 (Infra testes) ✅ COMPLETO
- `.planning/phases/02-dashboard/02-02-PLAN.md` — Wave 2 (Dados + gráficos) ✅ COMPLETO
- `.planning/phases/02-dashboard/02-03-PLAN.md` — Wave 3 (app.py Streamlit) ✅ COMPLETO
- `.planning/phases/02-dashboard/02-04-PLAN.md` — Wave 4 (Deploy Railway) ⏳ CHECKPOINT ATIVO (Task 1 OK, Task 2 aguarda verificação)

## Infraestrutura
- API: https://contalibrasv2-production.up.railway.app
- App: https://conta-libras.vercel.app
- Banco: Supabase projeto `ythfochjtvaopadnuxiq` (sa-east-1)

## Decisions
- Fixtures conftest.py com linha Intérprete (q30/q41) para validar colunas esparsas no pivot JSONB
- test_auth.py usa hmac.compare_digest diretamente (sem Streamlit) para isolamento total dos testes
- LABELS_QUESTOES para q30-q41 usa rótulos genéricos descritivos (questionario_IHC.md só vai até q29)
- fillna(0) ausente no pivot — NaN preservado para perguntas de categoria (comportamento esparso correto)
- fetch_feedbacks() sem parâmetro de filtro — filtro de categoria é responsabilidade de app.py em memória
- Auth gate usa DASHBOARD_PASSWORD env var com fallback "" — senha vazia garante falha de auth (sem bypass)
- to_csv_bytes() com @st.cache_data sem TTL — cache invalida quando df_wide (argumento) muda

## Resume
- Plano 02-04 em checkpoint — Task 1 completa (dashboard/railway.json commitado, 5680902)
- Aguardando: pesquisador criar segundo serviço Railway, configurar DATABASE_URL e DASHBOARD_PASSWORD, verificar deploy no browser
- Resume signal: digitar "aprovado" após verificação bem-sucedida do dashboard

# State

## Current
- **Phase:** 2
- **Plan:** 2 (completo) → próximo: 02-03-PLAN.md (Wave 3)
- **Status:** in-progress — 2/4 planos completos
- **Last session:** 2026-06-05 — Plano 02-02 executado (database.py, transforms.py, charts.py)

## Plans — Fase 2 (Dashboard de Visualização)
- `.planning/phases/02-dashboard/02-01-PLAN.md` — Wave 1 (Infra testes) ✅ COMPLETO
- `.planning/phases/02-dashboard/02-02-PLAN.md` — Wave 2 (Dados + gráficos) ✅ COMPLETO
- `.planning/phases/02-dashboard/02-03-PLAN.md` — Wave 3 (app.py Streamlit) ⏳
- `.planning/phases/02-dashboard/02-04-PLAN.md` — Wave 4 (Deploy Railway) ⏳

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

## Resume
- Plano 02-02 completo — próximo: executar 02-03-PLAN.md (app.py Streamlit — auth gate, sidebar, gráficos, download CSV)
- `/gsd:execute-phase 2` após `/clear`

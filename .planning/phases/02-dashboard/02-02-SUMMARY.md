---
phase: 02-dashboard
plan: "02"
subsystem: dashboard
tags: [database, transforms, charts, plotly, pandas, psycopg2, pivot-jsonb, wave-2]
dependency_graph:
  requires: [02-01]
  provides: [dashboard/database.py, dashboard/transforms.py, dashboard/charts.py]
  affects: [02-03-PLAN.md]
tech_stack:
  added: []
  patterns: [urlparse-psycopg2-sslmode, st-cache-data-ttl, explode-pivot-jsonb, plotly-express-charts, GREEN-state-TDD-wave-2]
key_files:
  created:
    - dashboard/database.py
    - dashboard/transforms.py
    - dashboard/charts.py
  modified: []
decisions:
  - "LABELS_QUESTOES para q30..q41 usa rótulos genéricos descritivos (questionario_IHC.md só vai até q29 — perguntas específicas por categoria não estão documentadas no arquivo)"
  - "fillna(0) ausente no pivot — NaN preservado para perguntas de categoria (comportamento esparso correto)"
  - "charts.py importa transforms via 'from transforms import' (import relativo — funciona com pytest.ini testpaths=tests e execução de dentro de dashboard/)"
  - "fetch_feedbacks() sem parâmetro de filtro em database.py — filtro de categoria é responsabilidade de app.py em memória (padrão RESEARCH.md)"
metrics:
  duration: "~20 min"
  completed: "2026-06-05"
  tasks_completed: 2
  tasks_total: 2
  files_created: 3
  files_modified: 0
---

# Phase 2 Plan 02: Camada de Dados e Gráficos do Dashboard — Summary

**One-liner:** Conexão Supabase via urlparse+sslmode, pivot JSONB→colunas qN com NaN esparso, e 3 figuras Plotly (barras Likert, comparativo por categoria, timeline) — test_transforms.py RED→GREEN (8/8 PASSED).

---

## Tasks Completed

| # | Task | Commit | Files |
|---|------|--------|-------|
| 1 | Camada de dados — database.py e transforms.py | 9f6d9f8 | dashboard/database.py, dashboard/transforms.py |
| 2 | Camada de gráficos — charts.py | 7f72b87 | dashboard/charts.py |

---

## What Was Built

**`dashboard/database.py`:**
- `get_connection()`: replica exato do padrão `api/database.py` com `urlparse` + kwargs separados + `sslmode="require"` adicionado (obrigatório para Supabase Session Pooler em produção)
- `fetch_feedbacks()`: com `@st.cache_data(ttl="5m")` — SELECT completo da tabela `feedbacks`, retorna `pd.DataFrame` com colunas `id, nome, idade, categoria, respostas, criado_em`

**`dashboard/transforms.py`:**
- `pivot_respostas(df)`: expande campo JSONB `respostas` (list de dicts) em colunas `q4..q41` via `df.explode() + pivot_table()`. NaN preservado para questões de categoria não respondidas (comportamento esparso correto). Trata edge case de DataFrame vazio.
- `build_wide_df(df)`: wrapper de `pivot_respostas()` — mesmo resultado, mantido por clareza de API
- `build_timeline_df(df)`: agrupa respostas por data em `America/Sao_Paulo`, retorna colunas `data` e `respostas`
- `SECOES_IHC`: dict mapeando q4..q41 às 7 seções (Usabilidade SUS, Experiência UX, Qualidade do Conteúdo, Aprendizado, Aceitação TAM, Avaliação Geral, Perguntas por Categoria)
- `LABELS_QUESTOES`: dict com rótulos curtos para q4..q41 (q4-q29 baseados no questionario_IHC.md; q30-q41 com rótulos genéricos descritivos por categoria)

**`dashboard/charts.py`:**
- `chart_medias_por_questao(df_wide)`: `px.bar` com `range_y=[1,5]`, `height=500`, agrupado por seção com `COLOR_SEQUENCE_SECOES`, linha horizontal `y=3` ("Neutro")
- `chart_comparativo_categoria(df_wide)`: `px.bar` com `barmode="group"`, `height=450`, `COLOR_MAP` com 5 categorias
- `chart_timeline(df)`: `px.line` com `markers=True`, `height=350`, tz `America/Sao_Paulo`

---

## Verification Results

```
$ py -3.11 -m pytest dashboard/tests/ -x -q
........
8 passed in 0.05s

Testes incluídos:
  test_auth.py: 4/4 PASSED (mantidos do plano 01)
  test_transforms.py: 4/4 PASSED (RED→GREEN neste plano)
    - test_pivot_respostas: q4, q5 presentes, 3 linhas
    - test_csv_colunas: {id, nome, idade, categoria, criado_em, q4, q5, q30, q41} ⊆ colunas
    - test_timeline: colunas data e respostas, 3 grupos de data
    - test_pivot_respostas_vazio: DataFrame vazio retorna len==0
```

---

## Deviations from Plan

### Auto-fixed Issues

Nenhum bug encontrado — plano executado dentro dos parâmetros esperados.

### Observações

**1. [Ajuste de Contexto] LABELS_QUESTOES para q30-q41 usa rótulos genéricos**
- **Encontrado durante:** Tarefa 1
- **Situação:** `Feedback/questionario_IHC.md` vai apenas até q29. As perguntas q30-q41 (específicas por categoria) não estão documentadas no arquivo.
- **Ação tomada:** Usados rótulos descritivos genéricos no padrão `"qN — [Cat.] Pergunta específica N (Categoria)"` para q30-q41, conforme a estrutura documentada no RESEARCH.md ("q30-q32: Estudante/Intérprete/Outro", etc.)
- **Impacto:** Nenhum — os rótulos são informativos nos gráficos. Quando as perguntas específicas forem documentadas, basta atualizar LABELS_QUESTOES em transforms.py.
- **Não é desvio de regra:** comportamento esperado — o plano já sinalizava "verificar IDs exatos contra questionario_IHC.md".

---

## Known Stubs

Nenhum — todos os dados fluem de funções puras. Nenhum valor hardcoded nas funções de chart ou transform que bloqueia o objetivo do plano.

---

## Threat Flags

Nenhum — nenhuma nova superfície de rede adicionada. O padrão urlparse+sslmode+env_var estava planejado e foi implementado conforme o threat model (T-02-02 e T-02-03 mitigados).

---

## Self-Check: PASSED

- [x] dashboard/database.py existe e contém `sslmode="require"` dentro de psycopg2.connect()
- [x] dashboard/database.py NÃO contém `psycopg2.connect(os.environ[` (sem URL direta)
- [x] dashboard/database.py contém `@st.cache_data(ttl="5m")` acima de fetch_feedbacks
- [x] dashboard/transforms.py existe e exporta pivot_respostas, build_wide_df, build_timeline_df
- [x] dashboard/transforms.py contém SECOES_IHC com entradas para q4..q41 (7 seções)
- [x] dashboard/transforms.py contém LABELS_QUESTOES com entradas para q4..q41
- [x] dashboard/transforms.py NÃO usa fillna(0) no pivot (NaN preservado)
- [x] dashboard/transforms.py NÃO importa streamlit
- [x] dashboard/charts.py existe e exporta 3 funções de gráfico
- [x] dashboard/charts.py contém COLOR_MAP com 5 categorias
- [x] dashboard/charts.py: range_y=[1,5] em chart_medias_por_questao, height=500
- [x] dashboard/charts.py: barmode="group" em chart_comparativo_categoria, height=450
- [x] dashboard/charts.py: markers=True em chart_timeline, height=350
- [x] dashboard/charts.py NÃO contém chamada real a st.plotly_chart (apenas docstring)
- [x] dashboard/charts.py NÃO contém use_container_width (deprecated)
- [x] py -3.11 -m pytest dashboard/tests/ -x -q → 8/8 PASSED
- [x] Commit 9f6d9f8 existe (Tarefa 1)
- [x] Commit 7f72b87 existe (Tarefa 2)

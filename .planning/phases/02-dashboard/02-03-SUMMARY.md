---
phase: 02-dashboard
plan: "03"
subsystem: dashboard
tags: [streamlit, auth, sidebar, plotly, csv-export, empty-state, error-state, wave-3]
dependency_graph:
  requires: [02-01, 02-02]
  provides: [dashboard/app.py]
  affects: [02-04-PLAN.md]
tech_stack:
  added: []
  patterns: [hmac-compare-digest-auth-gate, st-session-state-auth, st-sidebar-selectbox-filter, st-plotly-chart-stretch, st-download-button-csv, empty-state-st-warning-stop, db-error-state-st-error-stop]
key_files:
  created:
    - dashboard/app.py
  modified: []
decisions:
  - "Auth gate usa hmac.compare_digest com DASHBOARD_PASSWORD env var — sem fallback com senha real (senha vazia = hmac falha para qualquer input)"
  - "Filtro de categoria aplicado em memória após fetch_feedbacks() — sem nova query ao banco (conforme RESEARCH.md Anti-Patterns)"
  - "Empty state de DB vazio (len(df_raw)==0) exibido antes do pivot — separado do empty state pós-filtro"
  - "to_csv_bytes() decorada com @st.cache_data sem TTL — cache invalida automaticamente quando df_wide muda (argumento da função)"
  - "width='stretch' em todos os st.plotly_chart — use_container_width=True está deprecated desde Streamlit 1.40+"
metrics:
  duration: "~15 min"
  completed: "2026-06-05"
  tasks_completed: 1
  tasks_total: 1
  files_created: 1
  files_modified: 0
---

# Phase 2 Plan 03: Entrypoint Streamlit — app.py — Summary

**One-liner:** Dashboard Streamlit com auth gate hmac + DASHBOARD_PASSWORD env var, sidebar com filtro de categoria, 3 métricas de resumo, 3 gráficos Plotly via width="stretch", download CSV, empty state e DB error state — 8/8 testes PASSED.

---

## Tasks Completed

| # | Task | Commit | Files |
|---|------|--------|-------|
| 1 | app.py — entrypoint Streamlit completo | f66f579 | dashboard/app.py |

---

## What Was Built

**`dashboard/app.py`:**

**Auth gate (D-04, T-02-05):**
- `check_password()`: layout centralizado com `st.columns([1,2,1])[1]`, `st.header("Acesso Restrito")`, `st.text_input` tipo password, `st.button("Acessar Dashboard")`
- `hmac.compare_digest(entered, correct)` — resistente a timing attacks
- `correct = os.environ.get("DASHBOARD_PASSWORD", "")` — sem hardcode, sem fallback com senha real
- `st.session_state["authenticated"]` para persistir entre reruns
- `st.error("Senha incorreta. Tente novamente.")` em caso de falha
- `if not check_password(): st.stop()` antes de qualquer conteúdo

**Sidebar (D-10):**
- `st.sidebar.title("Filtros")`
- `st.sidebar.selectbox("Categoria de Usuário", ["Todos", "Pessoa surda", "Professor", "Estudante", "Intérprete", "Outro"])` — "Todos" como default
- `st.sidebar.caption("Filtro aplicado a todos os gráficos.")`

**Carregamento e transformação:**
- `try/except Exception` em torno de `fetch_feedbacks()` — DB error state com `st.error + st.stop`
- Verificação de `len(df_raw) == 0` — st.info + st.stop (banco ainda vazio)
- `pivot_respostas(df_raw)` para obter df_wide com colunas qN
- Filtro de categoria em memória (pandas), sem nova query
- Verificação de `len(df_wide) == 0` — empty state com `st.warning + st.stop`

**Seção 1 — Resumo Geral (D-06):**
- `st.columns(3)` + `st.metric` com labels "Total de Respostas", "Média Geral" (`.2f`), "Categorias Ativas"

**Seção 2 — Médias por Questão (D-07):**
- `chart_medias_por_questao(df_wide)` + `st.plotly_chart(fig1, width="stretch")`

**Seção 3 — Comparativo por Categoria (D-08):**
- `chart_comparativo_categoria(df_wide)` + `st.plotly_chart(fig2, width="stretch")`

**Seção 4 — Timeline (D-09):**
- `chart_timeline(df_raw_filtrado)` + `st.plotly_chart(fig3, width="stretch")`

**Seção 5 — Exportação CSV (D-11, D-12):**
- `@st.cache_data` em `to_csv_bytes(df)` — cache por argumento (sem TTL desnecessário)
- `st.columns([3, 1])`: descrição à esquerda, botão à direita
- `st.download_button(label="Exportar CSV", file_name="feedbacks_contalibras.csv", mime="text/csv")`

---

## Verification Results

```
$ py -3.11 -m pytest dashboard/tests/ -v
platform win32 -- Python 3.11.7, pytest-9.0.3
collected 8 items

dashboard\tests\test_auth.py::test_hmac_senha_correta PASSED          [ 12%]
dashboard\tests\test_auth.py::test_hmac_senha_errada PASSED           [ 25%]
dashboard\tests\test_auth.py::test_hmac_senha_vazia PASSED            [ 37%]
dashboard\tests\test_auth.py::test_hmac_timing_safe PASSED            [ 50%]
dashboard\tests\test_transforms.py::test_pivot_respostas PASSED       [ 62%]
dashboard\tests\test_transforms.py::test_csv_colunas PASSED           [ 75%]
dashboard\tests\test_transforms.py::test_timeline PASSED              [ 87%]
dashboard\tests\test_transforms.py::test_pivot_respostas_vazio PASSED [100%]

8 passed in 0.05s

$ py -3.11 -c "import py_compile; py_compile.compile('dashboard/app.py', doraise=True); print('Sintaxe OK')"
Sintaxe OK
```

---

## Deviations from Plan

None — plano executado exatamente como escrito.

---

## Known Stubs

Nenhum — todos os componentes estão conectados às camadas reais (database.py, transforms.py, charts.py). O dashboard está completo e funcional localmente com `DASHBOARD_PASSWORD=<senha> streamlit run app.py`.

---

## Threat Flags

Nenhum — todas as superfícies de segurança estavam no threat model planejado:
- T-02-05 (auth gate hmac.compare_digest): implementado conforme especificado
- T-02-07 (DASHBOARD_PASSWORD env var sem hardcode): implementado — `os.environ.get("DASHBOARD_PASSWORD", "")` com fallback vazio que garante falha de auth
- T-02-06 (CSV com dados pessoais): protegido pelo auth gate

---

## Self-Check: PASSED

- [x] dashboard/app.py existe e passa py_compile.compile sem erros
- [x] app.py contém `hmac.compare_digest` (comparação segura, D-04)
- [x] app.py contém `os.environ.get("DASHBOARD_PASSWORD", "")` — sem hardcode de senha
- [x] app.py contém `if not check_password(): st.stop()` antes de qualquer conteúdo
- [x] app.py contém `st.sidebar.selectbox` com "Todos" como primeira opção
- [x] app.py contém `st.metric` com "Total de Respostas", "Média Geral", "Categorias Ativas"
- [x] app.py contém `chart_medias_por_questao`, `chart_comparativo_categoria`, `chart_timeline`
- [x] app.py contém `st.plotly_chart` com `width="stretch"` — sem `use_container_width`
- [x] app.py contém `st.download_button` com `file_name="feedbacks_contalibras.csv"`
- [x] app.py contém `st.warning` + `st.stop()` para empty state pós-filtro
- [x] app.py contém `st.error` + `st.stop()` para DB error state
- [x] app.py NÃO contém `use_container_width=True`
- [x] py -3.11 -m pytest dashboard/tests/ -v → 8/8 PASSED
- [x] Commit f66f579 existe (Tarefa 1)

---
phase: 02-dashboard
plan: "01"
subsystem: dashboard
tags: [infra, tests, pytest, streamlit, configuration, wave-0]
dependency_graph:
  requires: []
  provides: [dashboard/requirements.txt, dashboard/pytest.ini, dashboard/.streamlit/config.toml, dashboard/tests/conftest.py, dashboard/tests/test_transforms.py, dashboard/tests/test_auth.py]
  affects: [02-02-PLAN.md, 02-03-PLAN.md]
tech_stack:
  added: [streamlit==1.58.0, plotly==6.8.0, pandas==3.0.3, psycopg2-binary>=2.9.9, python-dotenv>=1.0.0, pytest>=7.0.0]
  patterns: [pytest-fixtures-no-db, hmac.compare_digest-auth-test, RED-state-TDD-wave-0]
key_files:
  created:
    - dashboard/requirements.txt
    - dashboard/runtime.txt
    - dashboard/pytest.ini
    - dashboard/.streamlit/config.toml
    - dashboard/tests/__init__.py
    - dashboard/tests/conftest.py
    - dashboard/tests/test_transforms.py
    - dashboard/tests/test_auth.py
  modified: []
decisions:
  - "Fixtures conftest.py usam 3 linhas incluindo Intérprete com q30/q41 para validar colunas esparsas"
  - "test_auth.py usa hmac.compare_digest diretamente (sem check_password/Streamlit) para isolamento total"
  - "test_transforms.py em estado RED deliberado — aguarda transforms.py do plano 02"
metrics:
  duration: "~10 min"
  completed: "2026-06-05"
  tasks_completed: 2
  tasks_total: 2
  files_created: 8
  files_modified: 0
---

# Phase 2 Plan 01: Infra de Testes e Configuração do Dashboard — Summary

**One-liner:** Estrutura `dashboard/` com requirements.txt (versões exatas), pytest.ini, config.toml Streamlit e testes Wave 0 — test_auth.py verde (4/4) e test_transforms.py RED aguardando plano 02.

---

## Tasks Completed

| # | Task | Commit | Files |
|---|------|--------|-------|
| 1 | Arquivos de configuração do dashboard | cc01a56 | dashboard/requirements.txt, runtime.txt, pytest.ini, .streamlit/config.toml, tests/__init__.py |
| 2 | Fixtures de teste e testes unitários (Wave 0) | 24e96d1 | dashboard/tests/conftest.py, test_transforms.py, test_auth.py |

---

## What Was Built

Criada a pasta `dashboard/` na raiz do repositório com toda a infraestrutura de configuração e testes necessária para a Wave 0 do plano de visualização:

**Configuração:**
- `requirements.txt` com versões exatas: streamlit==1.58.0, plotly==6.8.0, pandas==3.0.3
- `runtime.txt` com `python-3.11` (padrão Railway — identico a api/runtime.txt)
- `pytest.ini` com `testpaths = tests` (execução isolada na pasta dashboard/)
- `.streamlit/config.toml` com tema `primaryColor = "#1f77b4"` conforme UI-SPEC

**Testes:**
- `conftest.py` com duas fixtures: `sample_raw_df` (3 linhas incluindo Intérprete com q30/q41) e `sample_raw_df_vazio`
- `test_transforms.py` com 4 testes em estado RED — ImportError esperado até plano 02 criar transforms.py
- `test_auth.py` com 4 testes PASS usando hmac.compare_digest (stdlib, sem Streamlit)

---

## Verification Results

```
$ py -3.11 -m pytest tests/test_auth.py -v
4 passed in 0.01s

$ py -3.11 -m pytest tests/test_transforms.py -v
4 failed — ModuleNotFoundError: No module named 'transforms'  [EXPECTED — RED state]
```

Estado correto: test_auth.py VERDE, test_transforms.py VERMELHO. O RED state é intencional — satisfaz o requisito Nyquist (VALIDATION.md Wave 0) de ter testes antes da implementação.

---

## Deviations from Plan

None — plano executado exatamente como escrito.

---

## Known Stubs

Nenhum — este plano cria apenas arquivos de configuração e testes. Nenhum dado de UI ou fonte de dados está vinculado.

---

## Threat Flags

Nenhum — nenhuma nova superfície de rede ou autenticação adicionada neste plano. Os testes usam apenas hmac da stdlib.

---

## Self-Check: PASSED

- [x] dashboard/requirements.txt existe e contém streamlit==1.58.0
- [x] dashboard/runtime.txt existe com python-3.11
- [x] dashboard/pytest.ini existe com testpaths = tests
- [x] dashboard/.streamlit/config.toml existe com primaryColor = "#1f77b4"
- [x] dashboard/tests/__init__.py existe
- [x] dashboard/tests/conftest.py existe com sample_raw_df e sample_raw_df_vazio
- [x] dashboard/tests/test_transforms.py existe com 4 testes (RED)
- [x] dashboard/tests/test_auth.py existe com 4 testes (GREEN)
- [x] Commit cc01a56 existe (Tarefa 1)
- [x] Commit 24e96d1 existe (Tarefa 2)

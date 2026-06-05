---
phase: 2
slug: 02-dashboard
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-06-05
---

# Phase 2 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | pytest |
| **Config file** | `dashboard/pytest.ini` — Wave 0 installs |
| **Quick run command** | `py -3.11 -m pytest dashboard/tests/ -x -q` |
| **Full suite command** | `py -3.11 -m pytest dashboard/tests/ -v` |
| **Estimated runtime** | ~5 seconds |

---

## Sampling Rate

- **After every task commit:** Run `py -3.11 -m pytest dashboard/tests/ -x -q`
- **After every plan wave:** Run `py -3.11 -m pytest dashboard/tests/ -v`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 30 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| pivot_respostas | core | 1 | D-07/D-08/D-11 | — | N/A | unit | `py -3.11 -m pytest dashboard/tests/test_transforms.py::test_pivot_respostas -x` | ❌ W0 | ⬜ pending |
| csv_colunas | core | 1 | D-11 | — | N/A | unit | `py -3.11 -m pytest dashboard/tests/test_transforms.py::test_csv_colunas -x` | ❌ W0 | ⬜ pending |
| check_password_errada | auth | 1 | D-04 | T-timing | hmac.compare_digest resistente a timing | unit | `py -3.11 -m pytest dashboard/tests/test_auth.py::test_senha_errada -x` | ❌ W0 | ⬜ pending |
| check_password_correta | auth | 1 | D-04 | T-timing | hmac.compare_digest resistente a timing | unit | `py -3.11 -m pytest dashboard/tests/test_auth.py::test_senha_correta -x` | ❌ W0 | ⬜ pending |
| timeline_agrupamento | core | 1 | D-09 | — | N/A | unit | `py -3.11 -m pytest dashboard/tests/test_transforms.py::test_timeline -x` | ❌ W0 | ⬜ pending |
| railway_json | deploy | 2 | D-02 | T-port | $PORT obrigatório no startCommand | smoke/manual | inspeção `dashboard/railway.json` contém `$PORT` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `dashboard/pytest.ini` — config básica pytest
- [ ] `dashboard/tests/__init__.py` — pacote de testes
- [ ] `dashboard/tests/conftest.py` — fixtures com DataFrame mock (sem banco)
- [ ] `dashboard/tests/test_transforms.py` — cobre pivot_respostas, csv_colunas, timeline
- [ ] `dashboard/tests/test_auth.py` — cobre check_password (senha correta e errada)

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Deploy Railway inicia sem erro | D-02 | Requer Railway CLI/dashboard | Verificar logs do serviço no Railway após push |
| Dashboard abre no browser após deploy | D-02/D-04 | Requer URL pública | Acessar URL Railway + inserir DASHBOARD_PASSWORD |
| Gráficos renderizam corretamente | D-06/D-07/D-08/D-09 | UI visual | Verificar cada seção no browser após deploy |
| Download CSV gerado corretamente | D-11/D-12 | Browser | Clicar "Exportar CSV" + abrir no Excel, verificar colunas q4..q41 |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending

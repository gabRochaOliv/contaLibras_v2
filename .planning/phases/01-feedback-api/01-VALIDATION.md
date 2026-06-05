---
phase: 1
slug: 01-feedback-api
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-06-04
---

# Phase 1 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework Flutter** | flutter_test (SDK — já presente no pubspec.yaml) |
| **Framework API Python** | pytest (Wave 0 instala: `pip install pytest httpx`) |
| **Config file** | Nenhum detectado — Wave 0 cria |
| **Quick run command (Flutter)** | `cd conta_libras_2 && flutter test` |
| **Quick run command (API)** | `cd api && pytest tests/ -x` |
| **Full suite command** | `cd conta_libras_2 && flutter test && cd ../api && pytest tests/` |
| **Estimated runtime** | ~30-60 segundos |

---

## Sampling Rate

- **Após cada task commit:** Rodar o quick run command do componente modificado
- **Após cada wave completa:** Rodar o full suite command
- **Antes do `/gsd:verify-work`:** Full suite deve estar verde
- **Latência máxima de feedback:** 60 segundos

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 01-01-T1 | 01-01 | 1 | D-11 | — | N/A | unit | `cd conta_libras_2 && flutter test test/user_manager_test.dart` | ❌ W0 | ⬜ pending |
| 01-01-T2 | 01-01 | 1 | D-08 | — | N/A | static | `cd conta_libras_2 && flutter analyze lib/core/constants.dart` | ❌ criado na task | ⬜ pending |
| 01-02-T1 | 01-02 | 1 | D-06, D-07 | SQL-inject | psycopg2 usa placeholders `%s` — sem f-strings | unit | `cd api && python -c "from main import app; from models import FeedbackPayload; print('import OK')"` | ❌ criado na task | ⬜ pending |
| 01-02-T2 | 01-02 | 1 | D-06 | — | N/A | integration | `cd api && pytest tests/test_feedback.py -v` | ❌ W0 | ⬜ pending |
| 01-03-T1 | 01-03 | 2 | D-10, D-12, D-13 | — | N/A | unit | `cd conta_libras_2 && flutter test test/feedback_service_test.dart` | ❌ W0 | ⬜ pending |
| 01-04-T1 | 01-04 | 3 | D-01, D-02, D-03, D-04 | — | N/A | static | `cd conta_libras_2 && flutter analyze lib/ui/widgets/evaluation_dialog.dart` | ❌ criado na task | ⬜ pending |
| 01-04-T2 | 01-04 | 3 | D-02, D-03, D-13 | — | N/A | widget | `cd conta_libras_2 && flutter test test/evaluation_dialog_test.dart` | ❌ W0 | ⬜ pending |
| 01-05-T1 | 01-05 | 4 | D-07 | — | N/A | manual | Setup Supabase + Railway (ação humana) | N/A — checkpoint | ⬜ pending |
| 01-05-T2 | 01-05 | 4 | D-06, D-08 | — | N/A | static | `cd conta_libras_2 && flutter analyze lib/core/constants.dart && echo "constants OK"` | ❌ criado em 01-01 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `conta_libras_2/test/user_manager_test.dart` — stubs para D-11 (UserManager persiste campo `age`)
- [ ] `conta_libras_2/test/feedback_service_test.dart` — stubs para D-10 e D-13 (payload correto + estado de erro)
- [ ] `conta_libras_2/test/evaluation_dialog_test.dart` — stubs para D-02, D-03, D-13 (navegação por seção + retry)
- [ ] `api/tests/test_feedback.py` — stubs para D-06 (POST /feedback retorna 201 e 422)
- [ ] `api/tests/conftest.py` — fixtures compartilhadas (mock da conexão psycopg2)
- [ ] Framework install API: `pip install pytest httpx` — pytest não detectado no ambiente

*Wave 0 é criado pelos próprios plans (01-01 cria user_manager_test.dart; 01-02 cria test_feedback.py; 01-03 cria feedback_service_test.dart; 01-04 cria evaluation_dialog_test.dart).*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Setup PostgreSQL no Supabase (criar tabela `feedbacks`) | D-07 | Requer acesso ao dashboard Supabase — não automatizável | Dashboard Supabase → SQL Editor → rodar script do Plan 01-05 |
| Deploy da API no Railway com DATABASE_URL | D-06 | Requer conta Railway e variável de ambiente | Railway dashboard → New Project → configurar DATABASE_URL + deploy |
| Verificar POST real do Flutter → Railway → Supabase | D-08, D-10 | Requer ambiente completo (Railway + Supabase provisionados) | Abrir app no Vercel → completar questionário → verificar registro no Supabase |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 60s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending

# Phase 2: Dashboard de Visualização — Pattern Map

**Mapped:** 2026-06-05
**Files analyzed:** 8 new files
**Analogs found:** 7 / 8

---

## File Classification

| New File | Role | Data Flow | Closest Analog | Match Quality |
|----------|------|-----------|----------------|---------------|
| `dashboard/database.py` | utility | request-response | `api/database.py` | exact |
| `dashboard/app.py` | controller | request-response | `api/main.py` | role-match |
| `dashboard/requirements.txt` | config | — | `api/requirements.txt` | exact |
| `dashboard/railway.json` | config | — | `api/Procfile` | role-match |
| `dashboard/runtime.txt` | config | — | `api/runtime.txt` | exact |
| `dashboard/tests/conftest.py` | test | — | `api/tests/conftest.py` | role-match |
| `dashboard/tests/test_transforms.py` | test | — | `api/tests/test_feedback.py` | role-match |
| `dashboard/.streamlit/config.toml` | config | — | — | no analog |

---

## Pattern Assignments

### `dashboard/database.py` (utility, request-response)

**Analog:** `api/database.py`

**Imports pattern** (`api/database.py` lines 1–7):
```python
import os
import psycopg2
from dotenv import load_dotenv
from urllib.parse import urlparse

load_dotenv()
```

**Core connection pattern** (`api/database.py` lines 10–18) — CRITICAL, copy exactly:
```python
def get_connection():
    url = urlparse(os.environ["DATABASE_URL"])
    return psycopg2.connect(
        host=url.hostname,
        port=url.port,
        database=url.path.lstrip("/"),
        user=url.username,
        password=url.password,
    )
```

**Deviation from analog:** Add `sslmode="require"` as an extra kwarg to `psycopg2.connect()` — Supabase Session Pooler requires SSL in production on Railway. The `api/database.py` omits it (works in current env) but the dashboard MUST include it per RESEARCH.md Pitfall 1.

**Query + close pattern** (`api/database.py` lines 21–35):
```python
conn = get_connection()
try:
    with conn.cursor() as cur:
        cur.execute("...", (params,))
    conn.commit()
finally:
    conn.close()
```

---

### `dashboard/app.py` (controller, request-response)

**Analog:** `api/main.py` (structural reference only — different framework)

**Structural reference** (`api/main.py` lines 1–27):
```python
# api/main.py entry point structure (FastAPI analog):
# 1. imports
# 2. app instantiation
# 3. middleware / config
# 4. route handlers with try/except

from fastapi import FastAPI, HTTPException
...
@app.post("/feedback", status_code=201)
def post_feedback(payload: FeedbackPayload):
    try:
        insert_feedback(payload)
        return {"message": "Feedback recebido com sucesso"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
```

**Streamlit entry point pattern** (from RESEARCH.md Pattern 4 — auth gate at top):
```python
# Replicate this gating structure at the top of app.py
import hmac, os, streamlit as st

def check_password() -> bool:
    def _verify():
        entered = st.session_state.get("password_input", "")
        correct = os.environ.get("DASHBOARD_PASSWORD", "")
        if hmac.compare_digest(entered, correct):
            st.session_state["authenticated"] = True
        else:
            st.session_state["authenticated"] = False
            st.error("Senha incorreta.")
    if st.session_state.get("authenticated"):
        return True
    st.text_input("Senha", type="password", key="password_input", on_change=_verify)
    return False

if not check_password():
    st.stop()
```

**Cache + query pattern** (from RESEARCH.md Pattern 2):
```python
@st.cache_data(ttl="5m")
def load_data() -> pd.DataFrame:
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT id, nome, idade, categoria, respostas, criado_em FROM feedbacks ORDER BY criado_em DESC"
            )
            cols = [d[0] for d in cur.description]
            rows = cur.fetchall()
        return pd.DataFrame(rows, columns=cols)
    finally:
        conn.close()
```

Note: `api/database.py` uses `conn.cursor()` as context manager with `conn.commit()` — the dashboard omits `commit()` since it only does SELECT queries.

**Error handling pattern** (`api/main.py` lines 22–27):
```python
try:
    insert_feedback(payload)
    return {"message": "..."}
except Exception as e:
    raise HTTPException(status_code=500, detail=str(e))
```
Dashboard analog: wrap `load_data()` call in `try/except Exception` and display `st.error(str(e))` + `st.stop()`.

---

### `dashboard/requirements.txt` (config)

**Analog:** `api/requirements.txt` (lines 1–7)

**Full analog file:**
```
fastapi>=0.110.0,<1.0.0
uvicorn[standard]>=0.29.0
pydantic>=2.6.0,<3.0.0
psycopg2-binary>=2.9.9
python-dotenv>=1.0.0
pytest>=7.0.0
httpx>=0.24.0
```

**Pattern to follow:** Pin format is `package>=MIN,<MAX` for framework packages; `package>=MIN` for drivers/tools. Dashboard uses the same `psycopg2-binary` and `python-dotenv` lines. Replace FastAPI/uvicorn/pydantic with Streamlit/Plotly/pandas at versions from RESEARCH.md Standard Stack:
```
streamlit==1.58.0
plotly==6.8.0
pandas==3.0.3
psycopg2-binary>=2.9.9
python-dotenv>=1.0.0
pytest>=7.0.0
```

---

### `dashboard/railway.json` (config)

**Analog:** `api/Procfile` (line 1):
```
web: uvicorn main:app --host 0.0.0.0 --port $PORT
```

**Pattern extracted:** The Procfile uses `$PORT` env var and `--host 0.0.0.0` — both mandatory for Railway. The dashboard upgrades this to `railway.json` format (no Procfile analog exists; RESEARCH.md Pattern 8 provides the target):
```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "NIXPACKS"
  },
  "deploy": {
    "startCommand": "streamlit run app.py --server.address 0.0.0.0 --server.port $PORT --server.fileWatcherType none --browser.gatherUsageStats false"
  }
}
```

Key mapping from Procfile pattern:
- `--host 0.0.0.0` → `--server.address 0.0.0.0`
- `--port $PORT` → `--server.port $PORT`
- `--server.fileWatcherType none` — extra flag to disable inotify (Railway containers)

---

### `dashboard/runtime.txt` (config)

**Analog:** `api/runtime.txt` (line 1):
```
python-3.11
```

**Pattern:** Copy exactly. Dashboard is a separate Railway service with its own `Root Directory: dashboard/`, so it needs its own `runtime.txt`.

---

### `dashboard/tests/conftest.py` (test)

**Analog:** `api/tests/conftest.py` (lines 1–23)

**Full analog:**
```python
import pytest
import httpx
from main import app

@pytest.fixture(scope="module")
def client():
    with httpx.Client(app=app, base_url="http://test") as c:
        yield c

@pytest.fixture
def valid_payload():
    return {
        "nome": "Ana",
        "idade": 22,
        "categoria": "Estudante",
        "respostas": [
            {"pergunta_id": 4, "valor": 5},
            {"pergunta_id": 29, "valor": 4},
        ],
        "timestamp": "2026-06-04T15:30:00.000Z",
    }
```

**Pattern to adapt:** Replace `client` fixture (HTTP client, not needed for unit tests) with a `sample_df` fixture providing a mock raw DataFrame (no DB connection). Keep the `valid_payload` pattern — dashboard equivalent is a fixture with mock `respostas` JSONB rows:
```python
import pytest
import pandas as pd

@pytest.fixture
def sample_raw_df():
    """DataFrame simulando retorno bruto do banco — sem conexão real."""
    return pd.DataFrame([
        {
            "id": 1,
            "nome": "Ana",
            "idade": 22,
            "categoria": "Estudante",
            "respostas": [
                {"pergunta_id": 4, "valor": 5},
                {"pergunta_id": 5, "valor": 4},
            ],
            "criado_em": "2026-06-01T10:00:00+00:00",
        },
        {
            "id": 2,
            "nome": "João",
            "idade": 30,
            "categoria": "Professor",
            "respostas": [
                {"pergunta_id": 4, "valor": 3},
                {"pergunta_id": 5, "valor": 2},
            ],
            "criado_em": "2026-06-02T11:00:00+00:00",
        },
    ])
```

---

### `dashboard/tests/test_transforms.py` (test)

**Analog:** `api/tests/test_feedback.py` (lines 1–45)

**Test structure pattern** (`api/tests/test_feedback.py` lines 1–45):
```python
import pytest

def test_health(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}

def test_feedback_valid_payload(client, valid_payload, monkeypatch):
    monkeypatch.setattr("database.insert_feedback", lambda p: None)
    response = client.post("/feedback", json=valid_payload)
    assert response.status_code == 201

def test_feedback_missing_field(client):
    ...
    assert response.status_code == 422
```

**Pattern to follow:** One function per behavior, `assert` on specific outputs, use `monkeypatch` to isolate from external dependencies. Dashboard tests use `sample_raw_df` fixture instead of HTTP client; test pure Python functions (no Streamlit):
```python
# Pattern: test pure transform functions, no Streamlit imports
def test_pivot_respostas(sample_raw_df):
    from transforms import pivot_respostas
    df_wide = pivot_respostas(sample_raw_df)
    assert "q4" in df_wide.columns
    assert "q5" in df_wide.columns
    assert len(df_wide) == 2

def test_csv_colunas(sample_raw_df):
    from transforms import pivot_respostas
    df_wide = pivot_respostas(sample_raw_df)
    required = {"id", "nome", "idade", "categoria", "criado_em", "q4", "q5"}
    assert required.issubset(set(df_wide.columns))
```

---

## Shared Patterns

### Database Connection (urlparse fix)
**Source:** `api/database.py` lines 10–18
**Apply to:** `dashboard/database.py`
```python
def get_connection():
    url = urlparse(os.environ["DATABASE_URL"])
    return psycopg2.connect(
        host=url.hostname,
        port=url.port,
        database=url.path.lstrip("/"),
        user=url.username,
        password=url.password,
        sslmode="require",   # ADD THIS — api/database.py omits it, dashboard needs it
    )
```
**Why mandatory:** Supabase Session Pooler username contains a dot (`postgres.PROJECT_REF`). Passing the URL string directly to `psycopg2.connect()` truncates it. This bug was fixed in Phase 1 (`api/` commit `1269447`).

### Query + finally-close Pattern
**Source:** `api/database.py` lines 24–35
**Apply to:** `dashboard/database.py`, `dashboard/app.py` (load_data)
```python
conn = get_connection()
try:
    with conn.cursor() as cur:
        cur.execute("SELECT ...", (params,))
        rows = cur.fetchall()
        cols = [d[0] for d in cur.description]
    return pd.DataFrame(rows, columns=cols)
finally:
    conn.close()
```

### Environment Variables (no .env in production)
**Source:** `api/database.py` lines 4, 7
**Apply to:** `dashboard/database.py`, `dashboard/app.py`
```python
from dotenv import load_dotenv
load_dotenv()  # no-op on Railway (env vars injected directly); loads .env locally
```
Pattern: `load_dotenv()` at module top level. On Railway, env vars are injected by the platform — `load_dotenv()` is harmless and enables local `.env` development.

### Test Fixture Pattern (mock without DB)
**Source:** `api/tests/conftest.py` lines 14–23
**Apply to:** `dashboard/tests/conftest.py`
```python
@pytest.fixture
def valid_payload():  # → rename to sample_raw_df for dashboard
    return { ... }   # provide mock data representing DB rows
```

### Procfile / startCommand Port Binding
**Source:** `api/Procfile` line 1
**Apply to:** `dashboard/railway.json`
```
# Procfile pattern:  --port $PORT  and  --host 0.0.0.0
# railway.json equivalent: --server.port $PORT  and  --server.address 0.0.0.0
```

---

## No Analog Found

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| `dashboard/.streamlit/config.toml` | config | — | No Streamlit config exists in the project; use RESEARCH.md pattern (minimal `[server]` section if needed; often can be omitted when all config is passed via CLI flags in `railway.json`) |

---

## Metadata

**Analog search scope:** `api/` directory (all files)
**Files scanned:** `api/database.py`, `api/main.py`, `api/requirements.txt`, `api/Procfile`, `api/runtime.txt`, `api/tests/conftest.py`, `api/tests/test_feedback.py`
**Pattern extraction date:** 2026-06-05

**Critical notes for planner:**
1. `api/database.py` does NOT include `sslmode="require"` — dashboard MUST add it (confirmed pitfall in RESEARCH.md).
2. `api/` uses `Procfile`; dashboard should use `railway.json` instead (upgrade, not copy).
3. `api/tests/` uses `httpx.Client` (HTTP integration tests) — dashboard tests should be pure unit tests on transform functions, no HTTP or Streamlit imports.
4. `psycopg2.extras.Json` import in `api/database.py` line 3 is NOT needed in dashboard (read-only, no INSERT).

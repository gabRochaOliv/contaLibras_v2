# Phase 2: Dashboard de Visualização — Research

**Researched:** 2026-06-05
**Domain:** Streamlit (Python) — Dashboard web com visualizações Likert + PostgreSQL/Supabase + Deploy Railway
**Confidence:** HIGH

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- **D-01:** Dashboard em **Streamlit** (Python) — alinha com o backend FastAPI/Python já existente, gráficos prontos, rápido de implementar para TCC.
- **D-02:** Deploy como **segundo serviço no Railway**, pasta `dashboard/` na raiz do repositório — isolado da API existente, deploy independente.
- **D-03:** Conexão ao banco via `DATABASE_URL` (mesma variável do Railway, apontando para Supabase Session Pooler) — reutiliza a infraestrutura já provisionada.
- **D-04:** Acesso protegido por **senha simples via Streamlit secrets** — uma variável de ambiente `DASHBOARD_PASSWORD` configurada no Railway.
- **D-05:** Público-alvo: pesquisador (TCC) + orientador/banca — sem necessidade de múltiplos usuários ou roles.
- **D-06:** Cards de resumo no topo: total de respostas, média geral, distribuição por categoria.
- **D-07:** Gráfico de barras por questão — média Likert (1–5) de cada uma das 29 perguntas IHC, agrupadas por seção.
- **D-08:** Comparativo por categoria — gráfico mostrando como cada categoria respondeu cada pergunta (ou média por seção).
- **D-09:** Timeline de coleta — gráfico de linha com volume de respostas por dia/semana.
- **D-10:** Filtro lateral por categoria de usuário.
- **D-11:** Botão de download CSV com dados brutos completos — colunas: `id`, `nome`, `idade`, `categoria`, `criado_em`, `q4`...`q41`.
- **D-12:** Formato adequado para análise no Excel/SPSS — dados brutos sem agregações.

### Claude's Discretion
- Estrutura interna de arquivos em `dashboard/` (app.py, database.py etc.)
- Padrão exato de caching com `@st.cache_data`
- Layout visual interno do Streamlit (order of sections, column widths)

### Deferred Ideas (OUT OF SCOPE)
- Análise automática/IA dos dados
- Autenticação multi-usuário com roles
- Gráficos de perguntas abertas (análise de texto)
</user_constraints>

---

## Summary

O Phase 2 cria um dashboard Streamlit separado que lê diretamente do PostgreSQL Supabase e expõe visualizações dos 29 itens Likert do questionário IHC. O desafio central é a transformação do campo `respostas JSONB` (array de `{pergunta_id, valor}`) em colunas tabulares pivoteadas — tanto para os gráficos quanto para a exportação CSV.

A stack é totalmente confirmada: Streamlit 1.58.0 (versão mais recente no PyPI), Plotly 6.8.0, pandas 3.0.3, psycopg2-binary 2.9.12. O padrão de conexão psycopg2 via `urlparse` já existe em `api/database.py` e deve ser replicado integralmente (sem usar `psycopg2.connect(url_string)` direto). O deploy Railway usa `railway.json` com `startCommand` em vez de Procfile, respeitando `$PORT` e `--server.address 0.0.0.0`.

A autenticação por senha usa `hmac.compare_digest` com `st.session_state` — padrão leve e suficiente para TCC. A variável `DASHBOARD_PASSWORD` é lida como `os.environ["DASHBOARD_PASSWORD"]` no Railway (Railway injeta env vars direto; não há suporte nativo a `secrets.toml` em plataformas não-Streamlit-Cloud).

**Primary recommendation:** Implementar `dashboard/app.py` com estrutura: (1) auth gate, (2) carregamento cacheado do banco, (3) pivot do JSONB, (4) sidebar com filtro, (5) métricas/cards, (6) gráficos plotly, (7) download CSV.

---

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Autenticação por senha | Frontend Server (Streamlit) | — | Streamlit controla todo o ciclo de request; session_state persiste auth entre reruns |
| Leitura do banco | Backend (psycopg2 direto) | — | Dashboard não passa pela API FastAPI; lê Supabase diretamente |
| Transformação JSONB → tabela | Processamento Python (pandas) | — | O JSONB retorna como dict Python do psycopg2; pivot feito em memória com pandas |
| Visualizações Likert | Frontend Streamlit (Plotly) | — | st.plotly_chart renderiza no browser via Streamlit server |
| Filtro lateral | Frontend Streamlit (sidebar) | — | st.sidebar.selectbox filtra DataFrame em memória antes dos gráficos |
| Exportação CSV | Frontend Streamlit | pandas | st.download_button + df.to_csv().encode() |
| Deploy / serviço | Railway (segundo serviço) | — | Root Directory: dashboard/, separado da API |

---

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| streamlit | 1.58.0 | Framework web + UI | Decisão locked (D-01); versão mais recente confirmada no PyPI [VERIFIED: PyPI registry] |
| plotly | 6.8.0 | Gráficos interativos | Integração nativa com `st.plotly_chart`; suporta barras agrupadas e line charts [VERIFIED: PyPI registry] |
| pandas | 3.0.3 | Manipulação tabular, pivot, CSV | Necessário para pivotar JSONB e exportar CSV [VERIFIED: PyPI registry] |
| psycopg2-binary | 2.9.12 | Driver PostgreSQL | Já usado na API (fase 1); padrão estabelecido [VERIFIED: PyPI registry] |
| python-dotenv | 1.2.2 | `.env` local (dev only) | Já usado na API; carrega `DATABASE_URL` localmente [VERIFIED: PyPI registry] |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| hmac (stdlib) | — | Comparação segura de senha | Embutido no Python; usado em `hmac.compare_digest` para evitar timing attacks |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| plotly | st.bar_chart (Altair nativo) | st.bar_chart é mais simples mas menos configurável; plotly permite barras agrupadas com legenda por categoria (D-08) |
| pandas pivot | SQL jsonb_array_elements() pivot | SQL resolve o pivot no banco mas aumenta complexidade da query; pandas em memória é mais simples para volume de TCC |
| os.environ direto | st.secrets | st.secrets só funciona bem no Streamlit Community Cloud ou com arquivo TOML; Railway injeta env vars — usar `os.environ` é mais direto e confiável [CITED: discuss.streamlit.io/t/provide-secrets-using-environment-variables] |

**Installation:**
```bash
pip install streamlit==1.58.0 plotly==6.8.0 pandas==3.0.3 psycopg2-binary==2.9.12 python-dotenv==1.2.2
```

---

## Package Legitimacy Audit

> Executado via `py -3.11 -m slopcheck install streamlit plotly pandas psycopg2-binary python-dotenv`

| Package | Registry | slopcheck | Disposition |
|---------|----------|-----------|-------------|
| streamlit | PyPI | [OK] | Aprovado |
| plotly | PyPI | [OK] | Aprovado |
| pandas | PyPI | [OK] | Aprovado |
| psycopg2-binary | PyPI | [OK] | Aprovado |
| python-dotenv | PyPI | [OK] (nota: nome parece "LLM bait" mas é pacote estabelecido) | Aprovado |

**Packages removed due to slopcheck [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

---

## Architecture Patterns

### System Architecture Diagram

```
Browser (pesquisador)
        |
        | HTTPS
        v
 [Streamlit Server — Railway dashboard/]
        |
        |-- auth gate (session_state + hmac)
        |
        |-- sidebar: st.sidebar.selectbox(categoria)
        |
        |-- @st.cache_data(ttl="5m")
        |       |
        |       v
        |   psycopg2 → Supabase Session Pooler
        |       |
        |       v
        |   cursor.fetchall() → raw rows
        |       |
        |       v
        |   pandas DataFrame
        |       |
        |       v
        |   explode(respostas) → pivot → df_wide
        |
        |-- cards (st.metric)
        |-- gráfico barras por questão (px.bar)
        |-- comparativo por categoria (px.bar grouped)
        |-- timeline coleta (px.line)
        |-- st.download_button (CSV)
```

### Recommended Project Structure

```
dashboard/
├── app.py              # Entrypoint Streamlit — toda a lógica da UI
├── database.py         # get_connection() replicando api/database.py
├── queries.py          # fetch_feedbacks() com @st.cache_data
├── transforms.py       # pivot_respostas(), build_wide_df()
├── charts.py           # funções que retornam fig plotly
├── auth.py             # check_password() com hmac
├── requirements.txt    # streamlit, plotly, pandas, psycopg2-binary, python-dotenv
├── runtime.txt         # python-3.11
└── railway.json        # builder NIXPACKS + startCommand
```

### Pattern 1: Conexão ao Banco (urlparse fix obrigatório)

**What:** Replica exato do `api/database.py` — obrigatório para Supabase Session Pooler (username com ponto)
**When to use:** Em todas as chamadas ao banco dentro do dashboard

```python
# Source: api/database.py (existente no projeto) + docs.streamlit.io/knowledge-base/tutorials/databases/postgresql
import os
import psycopg2
from urllib.parse import urlparse
from dotenv import load_dotenv

load_dotenv()

def get_connection():
    url = urlparse(os.environ["DATABASE_URL"])
    return psycopg2.connect(
        host=url.hostname,
        port=url.port,
        database=url.path.lstrip("/"),
        user=url.username,
        password=url.password,
        sslmode="require",
    )
```

> NUNCA usar `psycopg2.connect(os.environ["DATABASE_URL"])` direto — trunca o username com ponto do Session Pooler.

### Pattern 2: Cache de Dados com TTL

**What:** `@st.cache_data(ttl="5m")` para evitar re-query a cada rerun do Streamlit
**When to use:** Em toda função que faz SELECT no banco

```python
# Source: docs.streamlit.io/develop/api-reference/caching-and-state/st.cache_data
import streamlit as st
import pandas as pd

@st.cache_data(ttl="5m")
def fetch_feedbacks(categoria_filter: str = "Todos") -> pd.DataFrame:
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT id, nome, idade, categoria, respostas, criado_em
                FROM feedbacks
                ORDER BY criado_em DESC
            """)
            cols = [desc[0] for desc in cur.description]
            rows = cur.fetchall()
        df = pd.DataFrame(rows, columns=cols)
        return df
    finally:
        conn.close()
```

### Pattern 3: Pivot do JSONB `respostas` → colunas `q4`...`q41`

**What:** O campo `respostas` retorna do psycopg2 como lista Python (`[{"pergunta_id": 4, "valor": 3}, ...]`). Precisa ser expandido em colunas.
**When to use:** Antes de qualquer visualização ou exportação CSV

```python
# Source: padrão pandas explode + pivot_table — [ASSUMED] baseado em treinamento
import pandas as pd
import ast

def build_wide_df(df: pd.DataFrame) -> pd.DataFrame:
    """Transforma respostas JSONB em colunas q4..q41."""
    # psycopg2 retorna JSONB já como list de dicts Python
    df = df.copy()
    df["respostas"] = df["respostas"].apply(
        lambda x: x if isinstance(x, list) else ast.literal_eval(x)
    )
    # explode: uma linha por {pergunta_id, valor}
    df_exp = df.explode("respostas").reset_index(drop=True)
    df_exp["pergunta_id"] = df_exp["respostas"].apply(lambda x: x["pergunta_id"])
    df_exp["valor"] = df_exp["respostas"].apply(lambda x: x["valor"])
    # pivot: uma coluna por pergunta
    df_pivot = df_exp.pivot_table(
        index=["id", "nome", "idade", "categoria", "criado_em"],
        columns="pergunta_id",
        values="valor",
        aggfunc="first",
    ).reset_index()
    df_pivot.columns = (
        ["id", "nome", "idade", "categoria", "criado_em"]
        + [f"q{c}" for c in df_pivot.columns[5:]]
    )
    return df_pivot
```

> **Atenção:** `aggfunc="first"` assume no máximo uma resposta por pergunta por respondente — correto para o schema atual.

### Pattern 4: Autenticação por Senha (session_state + hmac)

**What:** Gate simples na entrada do app — senha única via env var
**When to use:** No topo de `app.py`, antes de qualquer conteúdo

```python
# Source: docs.streamlit.io/develop/concepts/connections/secrets-management + [ASSUMED] padrão hmac
import hmac
import os
import streamlit as st

def check_password() -> bool:
    """Retorna True se a senha está correta."""
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

# No topo de app.py:
if not check_password():
    st.stop()
```

> No Railway, `DASHBOARD_PASSWORD` é uma variável de ambiente comum — sem `secrets.toml`.

### Pattern 5: Gráfico de Barras por Questão (Médias Likert)

**What:** Barra horizontal por pergunta, média 1–5, agrupado por seção
**When to use:** Visualização principal (D-07)

```python
# Source: [ASSUMED] padrão plotly express + integração Streamlit
import plotly.express as px

def chart_medias_por_questao(df_wide: pd.DataFrame) -> object:
    q_cols = [c for c in df_wide.columns if c.startswith("q")]
    medias = df_wide[q_cols].mean().reset_index()
    medias.columns = ["questao", "media"]
    # mapeamento de labels (ver seções do questionário)
    fig = px.bar(
        medias, x="questao", y="media",
        labels={"questao": "Questão", "media": "Média (1–5)"},
        title="Médias Likert por Questão",
        range_y=[1, 5],
    )
    return fig

st.plotly_chart(fig, width="stretch")
```

### Pattern 6: Comparativo por Categoria (D-08)

**What:** Barras agrupadas — para cada seção/questão, uma barra por categoria
**When to use:** Análise-chave para o TCC (ver CONTEXT.md specifics)

```python
# Source: [ASSUMED] padrão plotly express grouped bar
import plotly.express as px

def chart_comparativo_categoria(df_wide: pd.DataFrame, q_cols: list) -> object:
    grp = df_wide.groupby("categoria")[q_cols].mean().reset_index()
    grp_long = grp.melt(id_vars="categoria", var_name="questao", value_name="media")
    fig = px.bar(
        grp_long, x="questao", y="media", color="categoria",
        barmode="group",
        title="Comparativo por Categoria de Usuário",
        range_y=[1, 5],
    )
    return fig
```

### Pattern 7: Download CSV (D-11)

**What:** Botão que entrega o df_wide como CSV com colunas q4..q41
**When to use:** Ao final da página

```python
# Source: docs.streamlit.io/knowledge-base/using-streamlit/how-download-pandas-dataframe-csv
@st.cache_data
def to_csv_bytes(df: pd.DataFrame) -> bytes:
    return df.to_csv(index=False).encode("utf-8")

st.download_button(
    label="Exportar CSV",
    data=to_csv_bytes(df_wide),
    file_name="feedbacks_contalibras.csv",
    mime="text/csv",
)
```

### Pattern 8: railway.json (deploy sem Procfile)

**What:** Configuração de deploy Railway — preferir `railway.json` sobre Procfile para Nixpacks
**When to use:** Arquivo raiz de `dashboard/`

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

> `--server.port $PORT` é obrigatório — Railway atribui a porta via env var `$PORT`, não é sempre 8501. [CITED: medium.com/@calebdame/hosting-streamlit-web-apps-on-railway-app]

### Anti-Patterns to Avoid

- **`psycopg2.connect(url_string)` direto:** Trunca username `postgres.PROJECT_REF` do Session Pooler — SEMPRE usar urlparse.
- **`st.cache_resource` para a função de dados:** Usar para conexão persistente, não para o DataFrame; use `@st.cache_data(ttl="5m")` para queries.
- **Hardcode de `DASHBOARD_PASSWORD` no código:** Jamais — Railway env var apenas.
- **`use_container_width=True` no st.plotly_chart:** Deprecated desde Streamlit 1.x — usar `width="stretch"` [CITED: docs.streamlit.io/develop/api-reference/charts/st.plotly_chart].
- **`@st.cache_data` em função sem TTL para queries:** Sem TTL, o cache não expira nunca — novos registros não aparecem sem restart.
- **Filtro de categoria em SQL:** Filtrar no pandas em memória é mais simples para o volume esperado (< 500 respostas) e permite atualizar o filtro instantaneamente sem nova query.
- **Procfile em vez de railway.json:** `railway.json` com `startCommand` é mais explícito e funciona melhor com Nixpacks no Railway. [CITED: medium.com/@calebdame, railway.com/deploy/streamlit]

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Gráficos interativos | charts HTML/CSS manuais | `plotly.express` + `st.plotly_chart` | Plotly tem barras agrupadas, hover, zoom — tudo nativo |
| Tabela de dados | HTML table manual | `st.dataframe(df)` | Streamlit nativo, sortable, sem código extra |
| Download CSV | link HTML com bytes | `st.download_button` | Nativo, lida com encoding e mime type automaticamente |
| Caching de queries | variável global / singleton manual | `@st.cache_data(ttl=...)` | Streamlit trata invalidação, hash de args, thread safety |
| Comparação de strings (senha) | `==` | `hmac.compare_digest` | Evita timing attacks — diferença de segurança real mesmo em TCC público |
| Pivot do JSONB | loop manual | `df.explode() + pivot_table()` | pandas trata edge cases (NaN, múltiplas linhas) corretamente |

**Key insight:** Streamlit já é um framework completo — resistir à tentação de recriar UI components que ele já oferece nativamente (metrics, download buttons, dataframes, sidebars).

---

## Mapeamento de Perguntas por Seção

A tabela abaixo é o mapeamento completo das 29 perguntas (IDs 4–41 no banco). Essencial para os rótulos dos gráficos (D-07).

| ID banco | Coluna CSV | Seção | Texto resumido |
|----------|------------|-------|----------------|
| 4 | q4 | Usabilidade (SUS) | Gostaria de usar com frequência |
| 5 | q5 | Usabilidade (SUS) | Fácil de usar |
| 6 | q6 | Usabilidade (SUS) | Funcionalidades bem integradas |
| 7 | q7 | Usabilidade (SUS) | Maioria aprenderia rápido |
| 8 | q8 | Usabilidade (SUS) | Navegação simples e intuitiva |
| 9 | q9 | Usabilidade (SUS) | Me senti confiante ao usar |
| 10 | q10 | Usabilidade (SUS) | Sem dificuldades significativas |
| 11 | q11 | Experiência (UX) | Design agradável |
| 12 | q12 | Experiência (UX) | Organização das telas facilita uso |
| 13 | q13 | Experiência (UX) | Responde rapidamente |
| 14 | q14 | Experiência (UX) | Visualmente claro |
| 15 | q15 | Qualidade do Conteúdo | Vídeos em Libras ajudam |
| 16 | q16 | Qualidade do Conteúdo | Descrições escritas claras |
| 17 | q17 | Qualidade do Conteúdo | Conteúdo relevante |
| 18 | q18 | Qualidade do Conteúdo | Informações confiáveis |
| 19 | q19 | Aprendizado | Contribuiu para aprendizado de Libras |
| 20 | q20 | Aprendizado | Facilitou compreensão de termos contábeis |
| 21 | q21 | Aprendizado | Útil como ferramenta educacional |
| 22 | q22 | Aprendizado | Pode ajudar na inclusão |
| 23 | q23 | Aceitação (TAM) | Útil para aprendizado de Libras |
| 24 | q24 | Aceitação (TAM) | Melhora acesso ao conhecimento |
| 25 | q25 | Aceitação (TAM) | Recomendaria para outras pessoas |
| 26 | q26 | Aceitação (TAM) | Utilizaria novamente no futuro |
| 27 | q27 | Avaliação Geral | Satisfeito com o aplicativo |
| 28 | q28 | Avaliação Geral | Atende às expectativas |
| 29 | q29 | Avaliação Geral | Potencial para auxiliar ensino de Libras |

> **ATENÇÃO:** O questionário IHC tem IDs 4–32 (perguntas 4 a 32, contando numeração do questionário_IHC.md). As linhas acima cobrem as 29 perguntas Likert (sem contar as 3 de perfil, IDs 1–3, que são `nome`, `idade`, `categoria` — já em colunas separadas na tabela).

---

## Common Pitfalls

### Pitfall 1: sslmode ausente na conexão psycopg2
**What goes wrong:** Conexão recusada ao Supabase com erro `SSL connection has been closed unexpectedly`
**Why it happens:** Supabase Session Pooler exige SSL — sem `sslmode="require"` a conexão falha em produção
**How to avoid:** Sempre passar `sslmode="require"` como kwarg na conexão (ver Pattern 1)
**Warning signs:** Funciona localmente (sem SSL) mas falha no Railway

### Pitfall 2: Cache Streamlit sem TTL em queries
**What goes wrong:** Novos registros inseridos não aparecem no dashboard sem restart manual do serviço
**Why it happens:** Sem `ttl`, `@st.cache_data` armazena indefinidamente
**How to avoid:** `@st.cache_data(ttl="5m")` — 5 minutos é razoável para dashboard de pesquisa
**Warning signs:** Dashboard mostra contagem estática mesmo após inserções confirmadas no banco

### Pitfall 3: JSONB retorna como string (não como list) em versões antigas do psycopg2
**What goes wrong:** `df["respostas"].apply(lambda x: x["pergunta_id"])` falha com `TypeError: string indices must be integers`
**Why it happens:** psycopg2 < 2.5.4 não deserializa JSONB automaticamente; ou cursor sem `RealDictCursor`
**How to avoid:** psycopg2-binary >= 2.9 deserializa JSONB como dict/list Python automaticamente. O `ast.literal_eval` no Pattern 3 é fallback de segurança
**Warning signs:** `type(row["respostas"])` retorna `str` ao invés de `list`

### Pitfall 4: `$PORT` não usado no startCommand
**What goes wrong:** Deploy Railway falha com `Health Check failed` — app escuta na porta errada
**Why it happens:** Streamlit por padrão usa 8501; Railway expõe porta dinamicamente via `$PORT`
**How to avoid:** Sempre usar `--server.port $PORT` no `startCommand` do `railway.json`
**Warning signs:** Serviço começa mas URL pública retorna 502/503

### Pitfall 5: `pivot_table` com pergunta duplicada por respondente
**What goes wrong:** `aggfunc="first"` silenciosamente descarta duplicatas; `aggfunc="mean"` distorce médias
**Why it happens:** Se o app Flutter enviou o mesmo `pergunta_id` duas vezes para o mesmo respondente
**How to avoid:** O schema atual não previne duplicatas no array JSONB — o planner deve adicionar task de validação dos dados existentes antes do pivot
**Warning signs:** `df_wide` tem menos colunas que o esperado (29 questões)

### Pitfall 6: Coluna `criado_em` como timezone-aware no pandas
**What goes wrong:** `pd.to_datetime(df["criado_em"])` gera warnings ou erros ao agrupar por dia
**Why it happens:** `TIMESTAMPTZ` do PostgreSQL retorna com timezone; pandas pode não lidar automaticamente
**How to avoid:** `df["criado_em"] = pd.to_datetime(df["criado_em"]).dt.tz_convert("America/Sao_Paulo")` antes de agrupar por data
**Warning signs:** Timeline (D-09) mostra timestamps em UTC ao invés de horário local

---

## Code Examples

### Fetch completo do banco e pivot

```python
# Source: padrão psycopg2 + pandas [ASSUMED] — baseado em api/database.py existente
import streamlit as st
import pandas as pd
from database import get_connection

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

def pivot_respostas(df: pd.DataFrame) -> pd.DataFrame:
    """Expande respostas JSONB em colunas q4..q41."""
    df = df.copy()
    df_exp = df.explode("respostas").reset_index(drop=True)
    df_exp["pid"] = df_exp["respostas"].apply(lambda x: x["pergunta_id"])
    df_exp["val"] = df_exp["respostas"].apply(lambda x: x["valor"])
    df_wide = df_exp.pivot_table(
        index=["id", "nome", "idade", "categoria", "criado_em"],
        columns="pid", values="val", aggfunc="first"
    ).reset_index()
    df_wide.columns = (
        ["id", "nome", "idade", "categoria", "criado_em"]
        + [f"q{c}" for c in df_wide.columns[5:]]
    )
    return df_wide
```

### Cards de resumo

```python
# Source: docs.streamlit.io/develop/api-reference/data/st.metric [ASSUMED] padrão
col1, col2, col3 = st.columns(3)
col1.metric("Total de Respostas", len(df))
col2.metric("Média Geral", f"{df_wide[q_cols].mean().mean():.2f}")
col3.metric("Categorias", df["categoria"].nunique())
```

### Timeline de coleta (D-09)

```python
# Source: [ASSUMED] padrão plotly express line
import plotly.express as px

def chart_timeline(df: pd.DataFrame) -> object:
    df = df.copy()
    df["data"] = pd.to_datetime(df["criado_em"]).dt.date
    timeline = df.groupby("data").size().reset_index(name="respostas")
    fig = px.line(timeline, x="data", y="respostas", title="Volume de Coleta por Dia", markers=True)
    return fig
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `st.cache` (global) | `@st.cache_data` / `@st.cache_resource` | Streamlit 1.18 | `st.cache` removido; usar decoradores específicos |
| `use_container_width=True` | `width="stretch"` | Streamlit ~1.40+ | `use_container_width` deprecated |
| Procfile no Railway | `railway.json` com `startCommand` | Railway Nixpacks era | `railway.json` é mais explícito; Procfile ainda funciona como fallback |

**Deprecated/outdated:**
- `st.cache`: completamente removido — jamais usar, substituído por `@st.cache_data` e `@st.cache_resource`
- `st.plotly_chart(use_container_width=True)`: deprecated, usar `width="stretch"`

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | psycopg2 retorna JSONB como `list` Python automaticamente (não como string) | Pattern 3, Pitfall 3 | Pivot falha; precisa de `json.loads()` adicional |
| A2 | Padrão de pivot com `df.explode() + pivot_table()` funciona corretamente para o schema atual | Pattern 3 / Code Examples | Pode precisar de abordagem alternativa se houver duplicatas de pergunta_id |
| A3 | Cards de resumo com `st.columns(3)` + `st.metric()` é o layout correto | Code Examples | Layout pode precisar de ajuste visual |
| A4 | `hmac.compare_digest` funciona com strings Python 3.11 sem encoding especial | Pattern 4 | Falha de autenticação; pode exigir `.encode()` em ambos os lados |
| A5 | `railway.json` é preferido sobre Procfile para Nixpacks no Railway | Pattern 8, Anti-patterns | Pode ser necessário Procfile como fallback |

---

## Open Questions

1. **Quantos respondentes são esperados durante o TCC?**
   - What we know: Dashboard para pesquisador/banca; volume provável < 200 respostas
   - What's unclear: TTL de 5 minutos no cache é adequado ou muito longo?
   - Recommendation: 5 min é adequado para o volume esperado; botão "Atualizar" com `st.cache_data.clear()` pode ser adicionado se necessário

2. **O Railway detecta automaticamente Python 3.11 com `runtime.txt`?**
   - What we know: `api/` já usa `runtime.txt` com `python-3.11`; pattern confirmado na fase 1
   - What's unclear: `dashboard/` como Root Directory separado precisa de `runtime.txt` próprio
   - Recommendation: Incluir `runtime.txt` em `dashboard/` com `python-3.11` (replicar o da API)

3. **Formato exato do `DASHBOARD_PASSWORD` no Railway**
   - What we know: Railway injeta como env var; lido via `os.environ["DASHBOARD_PASSWORD"]`
   - What's unclear: Caracteres especiais na senha precisam de escaping?
   - Recommendation: Usar senha alfanumérica simples para evitar problemas de escaping

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Python 3.11 | Dashboard Streamlit | ✓ | 3.11.7 (py -3.11) | — |
| pip (Python 3.11) | Instalação deps | ✓ | disponível | — |
| Railway (segundo serviço) | Deploy dashboard | ✓ (já usado fase 1) | N/A | — |
| Supabase PostgreSQL | Banco de dados | ✓ (provisionado fase 1) | PostgreSQL (sa-east-1) | — |
| DATABASE_URL (Railway env var) | Conexão banco | ✓ (já configurada fase 1) | — | — |

**Missing dependencies with no fallback:** nenhum — toda a infraestrutura está provisionada.

---

## Validation Architecture

> nyquist_validation não está explicitamente configurado em `.planning/config.json` (arquivo não existe) — tratado como habilitado.

### Test Framework

| Property | Value |
|----------|-------|
| Framework | pytest |
| Config file | `dashboard/pytest.ini` (Wave 0 — criar) |
| Quick run command | `pytest dashboard/tests/ -x -q` |
| Full suite command | `pytest dashboard/tests/ -v` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Existe? |
|--------|----------|-----------|-------------------|-------------|
| D-07/D-08/D-11 | `pivot_respostas()` produz colunas q4..q41 | unit | `pytest dashboard/tests/test_transforms.py::test_pivot_respostas -x` | ❌ Wave 0 |
| D-11 | CSV exportado tem colunas corretas | unit | `pytest dashboard/tests/test_transforms.py::test_csv_colunas -x` | ❌ Wave 0 |
| D-04 | `check_password()` rejeita senha errada | unit | `pytest dashboard/tests/test_auth.py::test_senha_errada -x` | ❌ Wave 0 |
| D-04 | `check_password()` aceita senha correta | unit | `pytest dashboard/tests/test_auth.py::test_senha_correta -x` | ❌ Wave 0 |
| D-09 | Timeline agrupa por data corretamente | unit | `pytest dashboard/tests/test_transforms.py::test_timeline -x` | ❌ Wave 0 |
| Deploy | `railway.json` tem `startCommand` com `$PORT` | smoke/manual | inspeção de arquivo | ❌ Wave 0 |

### Wave 0 Gaps

- [ ] `dashboard/tests/__init__.py` — pacote de testes
- [ ] `dashboard/tests/test_transforms.py` — cobre pivot, CSV, timeline
- [ ] `dashboard/tests/test_auth.py` — cobre check_password
- [ ] `dashboard/tests/conftest.py` — fixtures com DataFrame mock (sem banco)
- [ ] `dashboard/pytest.ini` — config básica

---

## Security Domain

> security_enforcement não configurado — tratado como habilitado.

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | sim (senha simples) | `hmac.compare_digest` + `st.session_state` |
| V3 Session Management | sim | Streamlit session_state (escopo de sessão HTTP) |
| V4 Access Control | sim | `st.stop()` antes de qualquer conteúdo protegido |
| V5 Input Validation | mínimo (apenas senha) | `hmac.compare_digest` — sem eval do input |
| V6 Cryptography | não se aplica | Senha em texto plano comparada; adequado para TCC interno |

### Known Threat Patterns for Streamlit + Railway

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Timing attack na comparação de senha | Tampering | `hmac.compare_digest` (resistente a timing) |
| Acesso a `DATABASE_URL` via código exposto | Info Disclosure | Env var Railway — nunca commitada; `.env` em `.gitignore` |
| SQL injection na query de feedbacks | Tampering | Query sem parâmetros de usuário (apenas SELECT *) — risco mínimo |
| Sessão Streamlit compartilhada entre usuários | Elevation of Privilege | `st.session_state` é por-sessão — não compartilhado entre usuários diferentes |

---

## Sources

### Primary (HIGH confidence)
- `api/database.py` (projeto) — padrão `urlparse` + psycopg2 confirmado e funcional em produção
- PyPI registry — versões de `streamlit==1.58.0`, `plotly==6.8.0`, `pandas==3.0.3`, `psycopg2-binary==2.9.12`, `python-dotenv==1.2.2` verificadas via `pip index versions`
- [docs.streamlit.io/develop/api-reference/charts/st.plotly_chart](https://docs.streamlit.io/develop/api-reference/charts/st.plotly_chart) — parâmetros `width="stretch"`, `use_container_width` deprecated
- [docs.streamlit.io/knowledge-base/using-streamlit/how-download-pandas-dataframe-csv](https://docs.streamlit.io/knowledge-base/using-streamlit/how-download-pandas-dataframe-csv) — padrão `st.download_button` + `df.to_csv().encode()`
- [docs.streamlit.io/develop/api-reference/caching-and-state/st.cache_data](https://docs.streamlit.io/develop/api-reference/caching-and-state/st.cache_data) — TTL, underscore prefix, cache_data vs cache_resource
- [docs.streamlit.io/knowledge-base/tutorials/databases/postgresql](https://docs.streamlit.io/knowledge-base/tutorials/databases/postgresql) — padrão conexão PostgreSQL no Streamlit

### Secondary (MEDIUM confidence)
- [medium.com/@calebdame/hosting-streamlit-web-apps-on-railway-app](https://medium.com/@calebdame/hosting-streamlit-web-apps-on-railway-app-8344a006405e) — `railway.json` com `startCommand`, `--server.port $PORT`
- [discuss.streamlit.io/t/provide-secrets-using-environment-variables](https://discuss.streamlit.io/t/provide-secrets-using-environment-variables/120749) — `os.environ` como abordagem para Railway (sem `secrets.toml`)
- slopcheck 0.6.1 — auditoria de pacotes (todos [OK])

### Tertiary (LOW confidence)
- Padrões de pivot `df.explode() + pivot_table()` — baseados em treinamento, não verificados via Context7 (ctx7 não disponível no ambiente)

---

## Metadata

**Confidence breakdown:**
- Standard Stack: HIGH — versões verificadas no PyPI registry + slopcheck [OK]
- Architecture: HIGH — baseada em infraestrutura existente confirmada (fase 1) e docs oficiais Streamlit
- Deploy Railway: MEDIUM — `railway.json` confirmado via fonte secundária (artigo Medium); padrão `$PORT` é consistente com Railway docs
- JSONB pivot: MEDIUM — padrão pandas está bem documentado; confirmação completa requer teste com dados reais
- Autenticação: HIGH — `hmac.compare_digest` + `session_state` é o padrão recomendado para Streamlit single-password apps

**Research date:** 2026-06-05
**Valid until:** 2026-08-05 (60 dias — Streamlit/plotly são estáveis; Railway pode mudar comportamentos de deploy)

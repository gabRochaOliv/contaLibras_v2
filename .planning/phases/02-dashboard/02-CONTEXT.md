# Phase 2: Dashboard de Visualização — Context

**Gathered:** 2026-06-05
**Status:** Ready for planning

<domain>
## Phase Boundary

Criar um dashboard web separado (não Flutter) para o pesquisador visualizar e analisar os feedbacks coletados — gráficos das respostas Likert, comparativos por categoria de usuário, timeline de coleta, e exportação de dados brutos em CSV.

</domain>

<decisions>
## Implementation Decisions

### Stack e Hospedagem
- **D-01:** Dashboard em **Streamlit** (Python) — alinha com o backend FastAPI/Python já existente, gráficos prontos, rápido de implementar para TCC.
- **D-02:** Deploy como **segundo serviço no Railway**, pasta `dashboard/` na raiz do repositório — isolado da API existente, deploy independente.
- **D-03:** Conexão ao banco via `DATABASE_URL` (mesma variável do Railway, apontando para Supabase Session Pooler) — reutiliza a infraestrutura já provisionada.

### Acesso e Autenticação
- **D-04:** Acesso protegido por **senha simples via Streamlit secrets** — uma variável de ambiente `DASHBOARD_PASSWORD` configurada no Railway.
- **D-05:** Público-alvo: pesquisador (TCC) + orientador/banca — sem necessidade de múltiplos usuários ou roles.

### Métricas e Visualizações
- **D-06:** Página principal com **cards de resumo** no topo:
  - Total de respostas coletadas
  - Média geral do questionário
  - Distribuição de respostas por categoria (Pessoa surda, Professor, Estudante, Intérprete, Outro)
- **D-07:** **Gráfico de barras por questão** — média Likert (1–5) de cada uma das 29 perguntas IHC, agrupadas por seção.
- **D-08:** **Comparativo por categoria** — gráfico mostrando como cada categoria de usuário respondeu cada pergunta (ou média por seção).
- **D-09:** **Timeline de coleta** — gráfico de linha com volume de respostas por dia/semana, para visualizar engajamento durante o período de pesquisa.
- **D-10:** Filtro lateral por categoria de usuário para filtrar todas as visualizações.

### Exportação
- **D-11:** Botão de download **CSV com dados brutos completos** — uma linha por resposta, com colunas: `id`, `nome`, `idade`, `categoria`, `criado_em`, e uma coluna por pergunta (`q4`, `q5`, ..., `q41`).
- **D-12:** Formato adequado para análise no Excel/SPSS — sem agregações, dados brutos completos.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Questionários e Dados
- `Feedback/questionario_IHC.md` — 29 perguntas IHC que foram implementadas (IDs 4–41), agrupadas por seção. Os IDs das perguntas são as chaves no campo `respostas` JSONB do banco.
- `Feedback/questionario.md` — questionário original com 21 perguntas + 3 abertas (referência para contexto).

### API e Banco de Dados
- `.planning/phases/01-feedback-api/01-02-SUMMARY.md` — estrutura da API FastAPI existente.
- `.planning/phases/01-feedback-api/01-05-SUMMARY.md` — infraestrutura Railway/Supabase, notas sobre Session Pooler (IPv4), urlparse fix para psycopg2.

### Schema do Banco
```sql
-- Tabela feedbacks (Supabase, projeto ythfochjtvaopadnuxiq, região sa-east-1)
CREATE TABLE feedbacks (
    id         SERIAL PRIMARY KEY,
    nome       VARCHAR(255)  NOT NULL,
    idade      INTEGER       NOT NULL,
    categoria  VARCHAR(100)  NOT NULL,
    respostas  JSONB         NOT NULL,  -- [{pergunta_id: int, valor: int}]
    criado_em  TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);
```

### Infraestrutura Existente
- API Railway: `https://contalibrasv2-production.up.railway.app`
- DATABASE_URL: Session Pooler Supabase (`aws-1-sa-east-1.pooler.supabase.com:5432`) — usar `urlparse` para conexão psycopg2 (não passar URL diretamente).

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `api/database.py` — padrão de conexão psycopg2 via urlparse + kwargs separados (obrigatório para Session Pooler).
- `api/requirements.txt` — dependências Python base (psycopg2-binary, python-dotenv, etc.).

### Established Patterns
- Conexão ao banco: sempre via `urlparse(DATABASE_URL)` + `psycopg2.connect(host=..., user=..., password=...)` — nunca `psycopg2.connect(url_string)` direto.
- Deploy Railway: Root Directory configurado como a pasta do serviço (`api` para a API; usar `dashboard` para o dashboard). Procfile com comando de start.
- Variáveis de ambiente sensíveis nunca commitadas — apenas no Railway.

### Integration Points
- O dashboard lê diretamente da tabela `feedbacks` no Supabase via psycopg2 — sem passar pela API FastAPI.
- Campo `respostas` é JSONB com array de `{pergunta_id: int, valor: int}` — precisa ser expandido/pivoteado para visualização e exportação CSV.

</code_context>

<specifics>
## Specific Ideas

- Comparativo por categoria é uma análise-chave para o TCC — deve ser destaque no dashboard, não apenas um filtro.
- Exportação CSV com uma coluna por pergunta (`q4`, `q5`, ...) facilita análise estatística no Excel/SPSS.
- Streamlit sidebar para filtro de categoria afeta todos os gráficos simultaneamente.

</specifics>

<deferred>
## Deferred Ideas

- Análise automática/IA dos dados — definida como out of scope no ROADMAP.md.
- Autenticação multi-usuário com roles — over-engineering para TCC.
- Gráficos de perguntas abertas (análise de texto) — se as perguntas abertas forem implementadas no futuro.

</deferred>

---

*Phase: 2-Dashboard de Visualização*
*Context gathered: 2026-06-05*

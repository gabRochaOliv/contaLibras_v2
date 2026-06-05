---
plan: 01-05
status: complete
wave: 4
depends_on: [01-02, 01-04]
---

# Resumo — Plano 01-05: Deploy e Integração

## O que foi feito
- Tabela `feedbacks` criada no Supabase via MCP (projeto `conta-libras-tcc`, região sa-east-1)
- API deployada no Railway: `https://contalibrasv2-production.up.railway.app`
- `constants.dart`: URL Railway real substituiu o placeholder
- `api/main.py`: CORS restrito a `https://conta-libras.vercel.app` + `http://localhost:*`
- `api/database.py`: conexão refatorada para usar `urlparse` (fix para username `postgres.project_ref` do Session Pooler)
- Flutter web rebuilt e pushed — Vercel redeploy com URL Railway de produção

## Verificações
- `GET /health`: `{"status": "ok"}` ✓
- `POST /feedback` com payload real: `{"message": "Feedback recebido com sucesso"}` (201) ✓
- `SELECT * FROM feedbacks`: linha de teste inserida com id=1 confirmada no Supabase ✓
- Flutter web rebuild com `kDebugMode=false` aponta para URL Railway real ✓

## Notas
- Direct connection (IPv6) não funciona no Railway — usar Session Pooler (IPv4, porta 5432)
- Senha do banco resetada via Supabase dashboard — senha anterior com `*` causava ambiguidade no pooler
- `psycopg2.connect(url_string)` trunca username com ponto: fix via `urlparse` + kwargs separados
- DATABASE_URL nunca commitada — apenas variável de ambiente no Railway

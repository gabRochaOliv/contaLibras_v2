# ContaLibras — Roadmap

## Milestone 1: Sistema de Coleta e Visualização de Feedbacks

### Phase 1: Coleta de Feedbacks e API
**Goal:** Implementar a coleta completa dos feedbacks dos usuários (questionário expandido + dados do perfil) e enviar para um backend que persiste os dados em banco de dados.

**Scope:**
- Expandir EvaluationDialog com as 29 perguntas do questionário IHC completo + perguntas por categoria
- Criar serviço no Flutter para enviar dados para API externa
- Criar API (Python/FastAPI) que recebe os dados e salva no banco
- Criar banco de dados (PostgreSQL/Supabase) para persistência
- Dados enviados: perfil do usuário (nome, idade, categoria) + respostas do questionário + timestamp

**Out of scope:**
- Dashboard de visualização (fase 2)
- Autenticação de pesquisadores
- Análise automática/IA dos dados

**Canonical refs:**
- `Feedback/questionario_IHC.md`
- `Feedback/questionario.md`
- `Feedback/termos.md`
- `conta_libras_2/lib/ui/widgets/evaluation_dialog.dart`
- `conta_libras_2/lib/data/managers/user_manager.dart`

**Plans:** 5 plans em 4 waves

**Wave 1** *(paralelo — sem dependências)*
- [ ] 01-01-PLAN.md — Flutter infra: UserManager (age), FirstAccessScreen, AppConstants, pubspec http
- [ ] 01-02-PLAN.md — API Python: FastAPI app, Pydantic models, psycopg2 database, deploy config, testes pytest

**Wave 2** *(bloqueado pela Wave 1 — requer 01-01)*
- [ ] 01-03-PLAN.md — FeedbackService: singleton HTTP service com submit, loading/error state

**Wave 3** *(bloqueado pela Wave 2 — requer 01-01 e 01-03)*
- [ ] 01-04-PLAN.md — EvaluationDialog: reescrita completa com 6 seções + categoria, submissão, error banner

**Wave 4** *(bloqueado pela Wave 3 — requer 01-02 e 01-04)*
- [ ] 01-05-PLAN.md — Deploy e integração: Supabase table, Railway deploy, URLs reais

**Cross-cutting constraints:**
- Todos os planos: usar import paths relativos (sem barrel exports nem `package:conta_libras_2/...`)
- Todos os planos Flutter: manter padrão Singleton ChangeNotifier dos managers existentes
- 01-02 e 01-05: DATABASE_URL apenas em variável de ambiente Railway — nunca no código-fonte

**Status:** complete

---

### Phase 2: Dashboard de Visualização
**Goal:** Criar interface separada (não Flutter) para visualizar e analisar os feedbacks coletados de forma organizada, com gráficos e filtros.

**Scope:**
- Dashboard web para visualizar respostas do questionário
- Filtros por categoria de usuário, data, etc.
- Gráficos das respostas Likert
- Exportação dos dados (CSV ou similar)

**Plans:** 4 plans em 4 waves

**Wave 1** *(sem dependências)*
- [ ] 02-01-PLAN.md — Infra de testes: requirements.txt, runtime.txt, pytest.ini, config.toml, fixtures, test_transforms.py (RED), test_auth.py (GREEN)

**Wave 2** *(bloqueado pela Wave 1 — requer 02-01)*
- [ ] 02-02-PLAN.md — Camada de dados e gráficos: database.py (urlparse+sslmode), transforms.py (pivot JSONB q4..q41), charts.py (3 figuras Plotly)

**Wave 3** *(bloqueado pela Wave 2 — requer 02-01 e 02-02)*
- [ ] 02-03-PLAN.md — Entrypoint Streamlit: app.py completo com auth gate, sidebar, 5 seções, empty/error states

**Wave 4** *(bloqueado pela Wave 3 — requer 02-03)*
- [ ] 02-04-PLAN.md — Deploy Railway: railway.json + segundo serviço Railway + verificação no browser (checkpoint)

**Cross-cutting constraints:**
- Todos os planos: DATABASE_URL e DASHBOARD_PASSWORD apenas como variáveis de ambiente Railway — nunca no código
- database.py: SEMPRE usar urlparse + kwargs separados (NUNCA psycopg2.connect(url_string)) — fix para Session Pooler Supabase
- database.py: SEMPRE incluir sslmode="require" — Supabase Session Pooler exige SSL em produção
- charts.py: NÃO usar use_container_width=True — deprecated; usar width="stretch" em st.plotly_chart

**Status:** planned

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

**Plans:** 5 plans

Plans:
- [ ] 01-01-PLAN.md — Flutter infra: UserManager (age), FirstAccessScreen, AppConstants, pubspec http
- [ ] 01-02-PLAN.md — API Python: FastAPI app, Pydantic models, psycopg2 database, deploy config, testes pytest
- [ ] 01-03-PLAN.md — FeedbackService: singleton HTTP service com submit, loading/error state
- [ ] 01-04-PLAN.md — EvaluationDialog: reescrita completa com 6 seções + categoria, submissão, error banner
- [ ] 01-05-PLAN.md — Deploy e integração: Supabase table, Railway deploy, URLs reais

**Status:** planning

---

### Phase 2: Dashboard de Visualização
**Goal:** Criar interface separada (não Flutter) para visualizar e analisar os feedbacks coletados de forma organizada, com gráficos e filtros.

**Scope:**
- Dashboard web para visualizar respostas do questionário
- Filtros por categoria de usuário, data, etc.
- Gráficos das respostas Likert
- Exportação dos dados (CSV ou similar)

**Status:** pending

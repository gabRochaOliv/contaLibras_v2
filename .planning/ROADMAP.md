# ContaLibras — Roadmap

## Milestone 1: Sistema de Coleta e Visualização de Feedbacks

### Phase 1: Coleta de Feedbacks e API
**Goal:** Implementar a coleta completa dos feedbacks dos usuários (questionário expandido + dados do perfil) e enviar para um backend que persiste os dados em banco de dados.

**Scope:**
- Expandir EvaluationDialog com as 21 perguntas do questionário completo + campos de texto abertos
- Criar serviço no Flutter para enviar dados para API externa
- Criar API (tecnologia a definir) que recebe os dados e salva no banco
- Criar banco de dados (tecnologia a definir) para persistência
- Dados enviados: perfil do usuário (nome, idade, categoria) + respostas do questionário + timestamp

**Out of scope:**
- Dashboard de visualização (fase 2)
- Autenticação de pesquisadores
- Análise automática/IA dos dados

**Canonical refs:**
- `Feedback/questionario.md`
- `Feedback/questionario_IHC.md`
- `Feedback/termos.md`
- `conta_libras_2/lib/ui/widgets/evaluation_dialog.dart`
- `conta_libras_2/lib/data/managers/user_manager.dart`

**Status:** pending

---

### Phase 2: Dashboard de Visualização
**Goal:** Criar interface separada (não Flutter) para visualizar e analisar os feedbacks coletados de forma organizada, com gráficos e filtros.

**Scope:**
- Dashboard web para visualizar respostas do questionário
- Filtros por categoria de usuário, data, etc.
- Gráficos das respostas Likert
- Exportação dos dados (CSV ou similar)

**Status:** pending

# Phase 1: Coleta de Feedbacks e API — Context

**Gathered:** 2026-06-03
**Status:** Ready for planning

<domain>
## Phase Boundary

Expandir o `EvaluationDialog` com o questionário completo (IHC + perguntas por categoria), criar uma API Python/FastAPI que recebe as respostas, e persistir os dados num banco PostgreSQL (Supabase). O app Flutter passa a enviar dados reais ao clicar em "Avaliar".

**In scope:**
- Expandir `EvaluationDialog` com 29 perguntas do `questionario_IHC.md`, navegação por seções agrupadas
- Adicionar perguntas específicas por categoria (Estudante, Professor, Pessoa surda, Intérprete de Libras) após as perguntas comuns
- Persistir a idade no `UserManager` (coletada mas ignorada atualmente)
- Criar serviço HTTP no Flutter (`FeedbackService`) para POST à API
- Criar API Python + FastAPI (deploy no Railway) com endpoint `POST /feedback`
- Criar banco PostgreSQL no Supabase (só banco, sem SDK do Supabase no Flutter)
- Tratamento de erro de envio: mostrar erro + botão "Tentar novamente"

**Out of scope:**
- Dashboard de visualização (Fase 2)
- Autenticação da API ou dos pesquisadores
- Análise automática/IA dos dados
- Restrição de múltiplas submissões
- SDK do Supabase no Flutter (usar só como banco PostgreSQL)

</domain>

<decisions>
## Implementation Decisions

### Questionário no app
- **D-01:** Usar `questionario_IHC.md` como base (29 perguntas Likert 1-5), com possibilidade de ajuste fino nas perguntas
- **D-02:** Navegação por seções agrupadas (SUS → UX → Qualidade do Conteúdo → Aprendizado → TAM → Geral), substituindo o modelo atual de uma pergunta por página
- **D-03:** Após as perguntas comuns, exibir seção adicional com perguntas específicas da categoria do usuário (Estudante, Professor, Pessoa surda, Intérprete de Libras)
- **D-04:** Categoria "Outro" recebe apenas as perguntas comuns — sem seção adicional
- **D-05:** Perguntas específicas por categoria precisam ser criadas (não existem ainda) — o executor deve propor um set inicial para aprovação ou deixar como placeholder estruturado

### Backend
- **D-06:** API customizada em Python + FastAPI, deploy no Railway
- **D-07:** Banco de dados: PostgreSQL no Supabase (usado apenas como banco, sem SDK Supabase no Flutter)
- **D-08:** Flutter chama a API via HTTP (`http` package), não conecta direto ao Supabase
- **D-09:** Stack funcional e apresentável, sem over-engineering — objetivo é TCC, não produção

### Dados do perfil enviados
- **D-10:** O payload do feedback inclui: `nome`, `idade`, `categoria`, `respostas` (lista de {pergunta_id, valor}), `timestamp`
- **D-11:** Persistir a `idade` no `UserManager` (atualmente coletada na `FirstAccessScreen` mas descartada) — ajustar `UserManager.setUserData()` para incluir a idade

### Submissões
- **D-12:** Múltiplas submissões permitidas sem restrição — cada envio gera uma nova linha no banco
- **D-13:** Em caso de falha de rede/API: mostrar mensagem de erro com botão "Tentar novamente" — questionário permanece aberto para reenvio

### Claude's Discretion
- Estrutura da tabela no banco (nomes de colunas, tipos) — seguir boas práticas PostgreSQL
- Estrutura dos endpoints FastAPI (versioning, schema, validação com Pydantic)
- Quais perguntas específicas por categoria sugerir (D-05) — propor e aguardar validação do usuário
- CORS na API para aceitar chamadas do domínio Vercel do app

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Questionários
- `Feedback/questionario_IHC.md` — Questionário base (29 perguntas Likert) que será implementado no app. Estruturado em SUS, UX, Qualidade do Conteúdo, Aprendizado, TAM, Avaliação Geral.
- `Feedback/questionario.md` — Questionário alternativo (21 Likert + 3 texto aberto). Referência para possíveis ajustes nas perguntas.
- `Feedback/termos.md` — Termos do TCLE (Termo de Consentimento Livre e Esclarecido).

### App Flutter — arquivos a modificar
- `conta_libras_2/lib/ui/widgets/evaluation_dialog.dart` — Dialog de avaliação atual (3 perguntas, navegação page-by-page). Será expandido.
- `conta_libras_2/lib/data/managers/user_manager.dart` — Gerenciador de dados do usuário. Adicionar campo `age`.
- `conta_libras_2/lib/ui/screens/first_access/first_access_screen.dart` — Coleta nome, idade, categoria. Ajustar para persistir a idade no UserManager.
- `conta_libras_2/pubspec.yaml` — Adicionar dependência `http` para chamadas HTTP.

### App Flutter — leitura de contexto
- `conta_libras_2/lib/ui/screens/home/home_screen.dart` — Botão "Avalie o app" que abre o EvaluationDialog.
- `conta_libras_2/lib/core/theme/app_colors.dart` — Paleta de cores para manter consistência visual.
- `conta_libras_2/lib/core/theme/app_text_styles.dart` — Estilos de texto para manter consistência.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `EvaluationDialog` com `PageController` e `PageView.builder`: estrutura de navegação pode ser adaptada para seções ao invés de perguntas individuais
- `AppColors` e `AppTextStyles`: usar para manter consistência visual no questionário expandido
- `_buildLikertScale(int questionIndex)`: componente de escala Likert (1-5) reutilizável — já existe e funciona bem
- `_buildTCLEView()`: TCLE já implementado — manter como primeira etapa antes das perguntas

### Established Patterns
- Singleton `ChangeNotifier` para managers (`UserManager`, `ProgressManager`, `ThemeManager`) — criar `FeedbackService` seguindo o mesmo padrão
- `AnimatedContainer` para transições no dialog — manter a experiência animada

### Integration Points
- `HomeScreen` → `EvaluationDialog`: o dialog é aberto via `showDialog()` em `home_screen.dart` — sem mudanças nesse ponto de entrada
- `FirstAccessScreen` → `UserManager.setUserData()`: ajustar para incluir `age` no setUserData
- `EvaluationDialog` → `FeedbackService`: ao concluir o questionário, chamar `FeedbackService.submit(answers, userProfile)`
- Flutter app → API Railway: HTTP POST para `https://api-contaLibras.railway.app/feedback` (URL a confirmar após deploy)

</code_context>

<specifics>
## Specific Ideas

- O app já está deployado no Vercel — a URL da API no Railway precisará ser configurada como constante no Flutter (possivelmente como variável de ambiente ou constante em `lib/core/constants.dart`)
- O questionário IHC tem seções bem definidas que mapeiam naturalmente para "páginas de seção" no dialog — cada seção vira uma tela com suas N perguntas, com barra de progresso entre seções
- A categoria do usuário já está disponível via `UserManager().userCategory` — o branching para perguntas por categoria é simples no Flutter
- FastAPI + Pydantic fornece validação automática do payload — usar schema Pydantic para o body do POST `/feedback`

</specifics>

<deferred>
## Deferred Ideas

- **Dashboard de visualização** — Interface web para visualizar os feedbacks coletados. Fase 2.
- **Autenticação de pesquisadores** — Proteger o acesso aos dados com login. Fase 2 ou além.
- **Análise automática dos dados / IA** — Processamento dos feedbacks com NLP ou estatísticas. Fora do escopo do TCC por ora.
- **Restrição de múltiplas submissões** — Controle via SharedPreferences para evitar duplicatas. Não necessário para o volume do TCC.
- **Campos de texto aberto** — Os 3 campos de sugestão do `questionario.md` não serão incluídos nesta fase.

</deferred>

---

*Phase: 01-feedback-api*
*Context gathered: 2026-06-03*

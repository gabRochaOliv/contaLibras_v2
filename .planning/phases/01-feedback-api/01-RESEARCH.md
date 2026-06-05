# Phase 1: Coleta de Feedbacks e API — Research

**Researched:** 2026-06-04
**Domain:** Flutter HTTP client + FastAPI Python + PostgreSQL Supabase
**Confidence:** HIGH

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- **D-01:** Usar `questionario_IHC.md` como base (29 perguntas Likert 1-5)
- **D-02:** Navegação por seções agrupadas (SUS → UX → Qualidade do Conteúdo → Aprendizado → TAM → Geral)
- **D-03:** Após perguntas comuns, exibir seção adicional com perguntas específicas da categoria
- **D-04:** Categoria "Outro" recebe apenas perguntas comuns — sem seção adicional
- **D-05:** Perguntas específicas por categoria precisam ser criadas — executor deve propor set inicial
- **D-06:** API customizada em Python + FastAPI, deploy no Railway
- **D-07:** Banco de dados: PostgreSQL no Supabase (usado apenas como banco, sem SDK Supabase no Flutter)
- **D-08:** Flutter chama a API via HTTP (`http` package), não conecta direto ao Supabase
- **D-09:** Stack funcional e apresentável, sem over-engineering — objetivo é TCC, não produção
- **D-10:** Payload inclui: `nome`, `idade`, `categoria`, `respostas` (lista de {pergunta_id, valor}), `timestamp`
- **D-11:** Persistir a `idade` no `UserManager` — ajustar `setUserData()` para incluir a idade
- **D-12:** Múltiplas submissões permitidas sem restrição
- **D-13:** Em falha de rede/API: mostrar erro + botão "Tentar novamente" — questionário permanece aberto

### Claude's Discretion

- Estrutura da tabela no banco (nomes de colunas, tipos) — seguir boas práticas PostgreSQL
- Estrutura dos endpoints FastAPI (versioning, schema, validação com Pydantic)
- Quais perguntas específicas por categoria sugerir (D-05) — propor e aguardar validação
- CORS na API para aceitar chamadas do domínio Vercel do app

### Deferred Ideas (OUT OF SCOPE)

- Dashboard de visualização (Fase 2)
- Autenticação de pesquisadores (Fase 2 ou além)
- Análise automática dos dados / IA
- Restrição de múltiplas submissões
- Campos de texto aberto (3 campos do `questionario.md`)
</user_constraints>

---

## Summary

Esta fase tem três componentes independentes que se integram num fluxo único: (1) o app Flutter recebe uma refatoração do `EvaluationDialog` para navegação por seções com 26+ perguntas Likert e submissão HTTP; (2) uma API Python/FastAPI recebe o payload e persiste no banco; (3) o banco PostgreSQL no Supabase armazena as respostas para análise posterior no TCC.

O maior risco técnico é a **compatibilidade de versões do Python**: a máquina local tem Python 3.7, que é incompatível com o FastAPI atual (requer Python >=3.10). O Railway provisiona Python 3.11 por padrão via Nixpacks — portanto o desenvolvimento da API deve acontecer diretamente para Railway, não testado localmente, a menos que uma versão Python compatível seja instalada. Alternativamente, um `runtime.txt` com `python-3.11` garante a versão no Railway independente do ambiente local.

O segundo ponto de atenção é a **conexão ao Supabase**: o Supabase fornece dois modos de conexão (porta 5432 para conexão direta, porta 6543 para transaction pooling). Para uma API simples de TCC sem alto volume de conexões, a porta 5432 (conexão direta) é a escolha mais simples e evita a configuração de `NullPool` e desativação de prepared statements.

**Primary recommendation:** Desenvolver a API FastAPI num diretório separado (`api/`) no repositório, com `requirements.txt` e `runtime.txt` declarando Python 3.11. Conectar ao Supabase pela string de conexão direta (porta 5432). O Flutter usa o pacote `http` com `dart:convert` para POST JSON — sem dependência adicional além de adicionar `http: ^1.2.0` no `pubspec.yaml`.

---

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Renderização do questionário | Flutter (cliente) | — | Dialog é widget local; sem estado remoto |
| Branching por categoria | Flutter (cliente) | — | `UserManager().userCategory` já disponível localmente |
| Validação "todas perguntas respondidas" | Flutter (cliente) | — | Gate antes de avançar seção — lógica de UI pura |
| Serialização do payload JSON | Flutter (cliente) | — | `dart:convert jsonEncode` antes do POST |
| Envio HTTP | Flutter (cliente) | — | `http.post()` para endpoint Railway |
| Tratamento de erro de rede | Flutter (cliente) | — | `try/catch` no FeedbackService; banner no dialog |
| Recepção e validação do payload | API FastAPI (Railway) | — | Pydantic schema valida campos obrigatórios |
| Persistência das respostas | API FastAPI (Railway) | PostgreSQL Supabase | API escreve via psycopg2 no banco |
| Armazenamento dos dados | PostgreSQL Supabase | — | Banco gerenciado; sem lógica de negócio |
| Perfil do usuário em memória | Flutter (cliente) | — | `UserManager` singleton — sem persistência local necessária |

---

## Standard Stack

### Core — Flutter

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| `http` | ^1.2.0 | HTTP POST JSON para a API | Pacote oficial Dart team; documentado em docs.flutter.dev [VERIFIED: pub.dev] |
| `dart:convert` | SDK built-in | `jsonEncode` / `jsonDecode` | Embutido no SDK Dart; sem instalação [VERIFIED: dart.dev] |

**Versão verificada:** `http` 1.6.0 é a última versão no pub.dev em 2026-06-04. `^1.2.0` garante compatibilidade com o SDK Dart 3.3.3 do projeto.

### Core — API Python

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| `fastapi` | >=0.110.0,<1.0.0 | Framework ASGI; roteamento, validação Pydantic | Padrão de mercado para APIs Python modernas [VERIFIED: pypi.org/project/fastapi] |
| `uvicorn[standard]` | >=0.29.0 | Servidor ASGI; Railway executa via Procfile/startCommand | Servidor ASGI de referência para FastAPI [VERIFIED: pypi.org/project/uvicorn] |
| `pydantic` | >=2.6.0,<3.0.0 | Validação do body do POST; schema do payload | Incluso no FastAPI; Pydantic v2 é o padrão atual [VERIFIED: pypi.org/project/pydantic] |
| `psycopg2-binary` | >=2.9.9 | Driver PostgreSQL para Python | Pacote `binary` evita compilação de dependências C no deploy [VERIFIED: pypi.org/project/psycopg2-binary] |
| `python-dotenv` | >=1.0.0 | Carregar `DATABASE_URL` do `.env` no desenvolvimento local | Padrão para gestão de variáveis de ambiente em Python [ASSUMED] |

**Nota de versão importante:** O `pip index` local retornou versões antigas porque a máquina usa Python 3.7. As versões acima são baseadas no que estará disponível no Railway (Python 3.11). O FastAPI 0.136.x atual requer Python >=3.10. [VERIFIED: pypi.org/project/fastapi]

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `httpx` | — | Cliente HTTP assíncrono para testes | Apenas se quiser testes automatizados da API |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `psycopg2-binary` | `asyncpg` | `asyncpg` é assíncrono e mais rápido, mas requer SQLAlchemy async. Para TCC síncrono é overkill |
| `psycopg2-binary` | `SQLAlchemy` ORM | SQLAlchemy abstrai o SQL, mas adiciona complexidade desnecessária para 1-2 queries simples |
| FastAPI | Flask | Flask é mais simples, mas FastAPI fornece validação Pydantic e docs Swagger automáticos — útil para TCC |

**Installation (Flutter):**
```bash
# Adicionar no pubspec.yaml > dependencies:
http: ^1.2.0
# Depois rodar:
flutter pub get
```

**Installation (API Python — requirements.txt):**
```
fastapi>=0.110.0,<1.0.0
uvicorn[standard]>=0.29.0
pydantic>=2.6.0,<3.0.0
psycopg2-binary>=2.9.9
python-dotenv>=1.0.0
```

**runtime.txt (Railway):**
```
python-3.11
```

---

## Package Legitimacy Audit

> slopcheck não pôde ser instalado (Python 3.7 local não suporta). Todos os pacotes abaixo foram verificados manualmente via PyPI oficial e são de autores/organizações reconhecidos.

| Package | Registry | Age | Downloads | Source Repo | slopcheck | Disposition |
|---------|----------|-----|-----------|-------------|-----------|-------------|
| `http` (Dart) | pub.dev | ~12 anos | >100M total | dart.dev (oficial Dart team) | N/A | Aprovado — pacote oficial |
| `fastapi` | PyPI | ~6 anos | >50M/sem | github.com/fastapi/fastapi | [ASSUMED OK] | Aprovado |
| `uvicorn` | PyPI | ~6 anos | >50M/sem | github.com/encode/uvicorn | [ASSUMED OK] | Aprovado |
| `pydantic` | PyPI | ~7 anos | >100M/sem | github.com/pydantic/pydantic | [ASSUMED OK] | Aprovado |
| `psycopg2-binary` | PyPI | ~10 anos | >10M/sem | github.com/psycopg/psycopg2 | [ASSUMED OK] | Aprovado |
| `python-dotenv` | PyPI | ~8 anos | >30M/sem | github.com/theskumar/python-dotenv | [ASSUMED OK] | Aprovado |

**Packages removed due to [SLOP] verdict:** nenhum
**Packages flagged as suspicious [SUS]:** nenhum

*slopcheck não estava disponível — todos os pacotes marcados [ASSUMED OK]. São bibliotecas amplamente conhecidas com histórico longo, mas o planner pode adicionar um checkpoint de verificação manual se desejar.*

---

## Architecture Patterns

### System Architecture Diagram

```
[Usuário no app Flutter]
         |
         v
[EvaluationDialog]
  - TCLE (aceitar/recusar)
  - Seções 1-6 (perguntas comuns, todos)
  - Seção 7 (perguntas por categoria, se aplicável)
  - Botão "Enviar Avaliação"
         |
         v
[FeedbackService.submit(payload)]
  - Monta JSON: {nome, idade, categoria, respostas, timestamp}
  - try: http.post(apiUrl, headers, body)
  - catch: lança FeedbackException
         |
         |-- success (2xx) --> Dialog fecha + SnackBar sucesso
         |-- error (4xx/5xx/network) --> Banner erro + botão retry
         |
         v
[API FastAPI no Railway]
  POST /feedback
  - Pydantic valida body
  - psycopg2 executa INSERT no PostgreSQL
  - retorna 201 Created
         |
         v
[PostgreSQL no Supabase]
  tabela: feedbacks
  - id (serial PK)
  - nome, idade, categoria
  - respostas (jsonb)
  - criado_em (timestamptz)
```

### Recommended Project Structure

```
/                           # raiz do repositório TCC
├── conta_libras_2/         # app Flutter (existente)
│   ├── lib/
│   │   ├── data/
│   │   │   ├── managers/
│   │   │   │   └── user_manager.dart     # MODIFICAR: adicionar campo age
│   │   │   └── services/
│   │   │       └── feedback_service.dart  # CRIAR: HTTP POST
│   │   ├── ui/
│   │   │   └── widgets/
│   │   │       └── evaluation_dialog.dart # MODIFICAR: expandir
│   │   └── core/
│   │       └── constants.dart             # CRIAR: API_BASE_URL
│   └── pubspec.yaml                       # MODIFICAR: adicionar http
└── api/                    # API FastAPI (CRIAR)
    ├── main.py             # FastAPI app + endpoint POST /feedback
    ├── models.py           # Pydantic schemas
    ├── database.py         # conexão psycopg2 com Supabase
    ├── requirements.txt    # dependências Python
    ├── runtime.txt         # python-3.11
    ├── Procfile            # web: uvicorn main:app --host 0.0.0.0 --port $PORT
    └── .env.example        # DATABASE_URL=postgresql://...
```

### Pattern 1: FeedbackService — Singleton ChangeNotifier

Seguir o padrão dos managers existentes (`UserManager`, `ProgressManager`).

**What:** Serviço que encapsula a lógica HTTP, expõe estado (`isLoading`, `hasError`) e notifica listeners.
**When to use:** Sempre que o EvaluationDialog precisar saber o estado do envio.

```dart
// lib/data/services/feedback_service.dart
// Source: padrão estabelecido em user_manager.dart + docs.flutter.dev/cookbook/networking/send-data
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../managers/user_manager.dart';
import '../../core/constants.dart';

class FeedbackService extends ChangeNotifier {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  bool _isLoading = false;
  bool _hasError = false;

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  Future<void> submit(Map<int, int> answers) async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    final user = UserManager();
    final payload = {
      'nome': user.userName,
      'idade': user.userAge,
      'categoria': user.userCategory,
      'respostas': answers.entries
          .map((e) => {'pergunta_id': e.key, 'valor': e.value})
          .toList(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/feedback'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(payload),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ${response.statusCode}');
      }
      _hasError = false;
    } catch (_) {
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### Pattern 2: UserManager com campo `age`

```dart
// Modificação em user_manager.dart
// ANTES: setUserData(String name, String category)
// DEPOIS:
int _userAge = 0;
int get userAge => _userAge;

void setUserData(String name, String category, int age) {
  _userName = name;
  _userCategory = category.isNotEmpty ? category : 'Estudante de Contábeis';
  _userAge = age;
  notifyListeners();
}
```

Em `FirstAccessScreen._submit()`:
```dart
// ANTES:
UserManager().setUserData(_nameController.text.trim(), _selectedCategory ?? '');
// DEPOIS:
UserManager().setUserData(
  _nameController.text.trim(),
  _selectedCategory ?? '',
  int.tryParse(_ageController.text) ?? 0,
);
```

### Pattern 3: FastAPI endpoint POST /feedback

```python
# api/main.py
# Source: fastapi.tiangolo.com/tutorial/first-steps + fastapi.tiangolo.com/tutorial/cors
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from models import FeedbackPayload
from database import insert_feedback

app = FastAPI(title="ContaLibras Feedback API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://conta-libras.vercel.app",  # URL real do app Vercel
        "http://localhost:*",                # desenvolvimento local
    ],
    allow_methods=["POST", "GET"],
    allow_headers=["*"],
)

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/feedback", status_code=201)
def receive_feedback(payload: FeedbackPayload):
    try:
        insert_feedback(payload)
        return {"message": "Feedback recebido com sucesso"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
```

### Pattern 4: Pydantic schema do payload

```python
# api/models.py
# Source: fastapi.tiangolo.com/tutorial/body
from pydantic import BaseModel
from typing import List
from datetime import datetime

class Resposta(BaseModel):
    pergunta_id: int
    valor: int  # 1-5

class FeedbackPayload(BaseModel):
    nome: str
    idade: int
    categoria: str
    respostas: List[Resposta]
    timestamp: datetime
```

### Pattern 5: Conexão psycopg2 com Supabase

```python
# api/database.py
# Source: supabase.com/docs/guides/database/connecting-to-postgres
import os
import json
import psycopg2
from psycopg2.extras import Json
from dotenv import load_dotenv

load_dotenv()

def get_connection():
    return psycopg2.connect(os.environ["DATABASE_URL"])

def insert_feedback(payload):
    conn = get_connection()
    try:
        cur = conn.cursor()
        respostas_json = [r.dict() for r in payload.respostas]
        cur.execute(
            """
            INSERT INTO feedbacks (nome, idade, categoria, respostas, criado_em)
            VALUES (%s, %s, %s, %s, %s)
            """,
            (payload.nome, payload.idade, payload.categoria,
             Json(respostas_json), payload.timestamp)
        )
        conn.commit()
    finally:
        conn.close()
```

### Pattern 6: SQL de criação da tabela (executar no Supabase SQL Editor)

```sql
-- Executar no Supabase Dashboard > SQL Editor
CREATE TABLE IF NOT EXISTS feedbacks (
    id          SERIAL PRIMARY KEY,
    nome        VARCHAR(255)  NOT NULL,
    idade       INTEGER       NOT NULL,
    categoria   VARCHAR(100)  NOT NULL,
    respostas   JSONB         NOT NULL,
    criado_em   TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- Índice para consultas por categoria (útil na Fase 2)
CREATE INDEX idx_feedbacks_categoria ON feedbacks(categoria);
CREATE INDEX idx_feedbacks_criado_em ON feedbacks(criado_em);
```

### Pattern 7: AppConstants com URL da API

```dart
// CRIAR: lib/core/constants.dart
class AppConstants {
  AppConstants._();

  // URL base da API. Substituir pela URL gerada pelo Railway após o deploy.
  static const String apiBaseUrl = 'https://api-conta-libras.railway.app';
  // Durante desenvolvimento local da API: 'http://localhost:8000'
}
```

### Anti-Patterns to Avoid

- **Conectar Flutter diretamente ao Supabase:** Decisão D-08 proíbe isso. O Flutter chama apenas a API Railway. String de conexão do banco nunca vai para o cliente.
- **Auto-advance no novo EvaluationDialog:** O padrão atual avança a página automaticamente ao selecionar resposta. Com múltiplas perguntas por seção, isso não se aplica — cada clique só registra a resposta, sem navegar.
- **Fechar o dialog em caso de erro:** Em falha de envio, o dialog deve permanecer aberto (D-13). Não chamar `Navigator.of(context).pop()` no catch.
- **Hardcode de credenciais do banco na API:** A `DATABASE_URL` deve vir de variável de ambiente Railway — nunca no código-fonte.
- **`allow_origins=["*"]` com `allow_credentials=True`:** Browsers recusam essa combinação. Para TCC sem cookies, usar `allow_origins` com domínio específico do Vercel ou `["*"]` sem credentials.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Validação do payload JSON recebido | Validação manual com `if`s | `pydantic.BaseModel` no FastAPI | Pydantic valida tipos, campos obrigatórios e retorna 422 automático com detalhes do erro |
| Serialização JSON no Flutter | Concatenação de strings | `dart:convert jsonEncode` | Embutido no SDK; escapa caracteres especiais corretamente |
| Conexão ao PostgreSQL | Driver TCP manual | `psycopg2` | Gerencia pool, prepared statements, transações e erros de conexão |
| CORS no FastAPI | Headers manuais por rota | `CORSMiddleware` do Starlette | Middleware trata preflight OPTIONS e adiciona headers em todas as respostas |
| Documentação da API | Escrever manualmente | Swagger UI automático do FastAPI (`/docs`) | FastAPI gera `/docs` com OpenAPI — útil para demonstrar no TCC |

**Key insight:** Para um TCC com um endpoint POST simples, o FastAPI já resolve validação, documentação e CORS sem código adicional.

---

## Common Pitfalls

### Pitfall 1: Python 3.7 local incompatível com FastAPI moderno

**What goes wrong:** `pip install fastapi` na máquina local instala a versão 0.103.2 (última para Python 3.7), que tem comportamentos diferentes do FastAPI 0.110+ que roda no Railway.
**Why it happens:** A máquina local tem Python 3.7.8; FastAPI >=0.110.0 requer Python >=3.10.
**How to avoid:** Declarar `runtime.txt` com `python-3.11` no diretório `api/`. Testar localmente com Python 3.11+ (via pyenv, conda ou WSL) ou testar diretamente no Railway via deploy. Alternativamente, instalar Python 3.11 no Windows e criar venv separado.
**Warning signs:** `pip install fastapi` instala versão <0.110 sem aviso — verificar `pip show fastapi | grep Version` após instalar.

### Pitfall 2: CORS bloqueando chamadas do Flutter web (Vercel)

**What goes wrong:** O app Flutter no Vercel faz POST para a API no Railway e o browser bloqueia com "CORS policy" no console.
**Why it happens:** O middleware CORS precisa estar configurado **antes** de qualquer rota no FastAPI, e precisa incluir o domínio exato do Vercel.
**How to avoid:** Adicionar `CORSMiddleware` logo após criar o `app = FastAPI()`. Incluir a URL Vercel do app na lista `allow_origins`. Testar com `curl` ou Postman antes de testar no Flutter.
**Warning signs:** Erros no console do browser com "Access-Control-Allow-Origin" ausente.

### Pitfall 3: `_answers` com índice global vs. por seção

**What goes wrong:** O `EvaluationDialog` atual usa `_answers[questionIndex]` com índice global (0, 1, 2). Ao expandir para 26+ perguntas divididas em seções, o índice pode colidir se não for normalizado.
**Why it happens:** Cada seção tem suas perguntas renumeradas internamente; o ID da pergunta precisa ser consistente com o `pergunta_id` enviado à API.
**How to avoid:** Usar o `id` da pergunta do questionário IHC (4 a 29 + IDs das perguntas por categoria) como chave do `Map<int, int> _answers`. Nunca usar o índice local da seção como chave.
**Warning signs:** Respostas duplicadas ou sobrepostas no payload enviado.

### Pitfall 4: `AnimatedContainer` com altura fixa insuficiente para seções longas

**What goes wrong:** A seção SUS tem 7 perguntas — o dialog com altura fixa `380` do modo perguntas atuais não comporta.
**Why it happens:** O `EvaluationDialog` atual tem `height: _hasAcceptedTerms ? 380 : ...` — 380px é suficiente para 1 pergunta, insuficiente para 7.
**How to avoid:** A UI-SPEC já define `MediaQuery.of(context).size.height * 0.85, max 700px` para o modo seções. Cada página de seção usa `SingleChildScrollView` internamente para overflow.
**Warning signs:** Overflow de layout no console Flutter com "A RenderFlex overflowed".

### Pitfall 5: URL da API hardcoded sem fallback para desenvolvimento local

**What goes wrong:** O `apiBaseUrl` aponta para a URL Railway em produção — durante o desenvolvimento do Flutter, se a API não estiver deployada, todos os POSTs falham.
**Why it happens:** Constante única sem diferenciação de ambiente.
**How to avoid:** Usar `kDebugMode` para alternar URL:
```dart
static String get apiBaseUrl => kDebugMode
    ? 'http://localhost:8000'
    : 'https://api-conta-libras.railway.app';
```
Ou configurar via `--dart-define` no build.
**Warning signs:** Timeout em todas as submissões durante desenvolvimento local.

### Pitfall 6: Supabase porta 5432 vs. 6543

**What goes wrong:** Usar a string de conexão Transaction Mode (porta 6543) com psycopg2 padrão lança `ProgrammingError: prepared statement already exists`.
**Why it happens:** Transaction pooling no Supabase não suporta prepared statements; psycopg2 usa prepared statements por padrão.
**How to avoid:** Usar a string de conexão direta (porta 5432) para a API de TCC. É mais simples e adequado para o volume de conexões esperado.
**Warning signs:** Erros de `prepared statement` nos logs da API no Railway.

---

## Code Examples

### Estrutura completa do `_questions` mapeado por seções

```dart
// Dentro do EvaluationDialog refatorado
// IDs correspondem às perguntas do questionario_IHC.md (Q4-Q29)

static const List<Map<String, dynamic>> _sections = [
  {
    'title': 'Usabilidade do Sistema (SUS)',
    'icon': Icons.tune,
    'questions': [
      {'id': 4,  'text': 'Eu gostaria de utilizar este aplicativo com frequência.'},
      {'id': 5,  'text': 'O aplicativo é fácil de usar.'},
      {'id': 6,  'text': 'As funcionalidades do aplicativo são bem integradas.'},
      {'id': 7,  'text': 'A maioria das pessoas conseguiria aprender a usar este aplicativo rapidamente.'},
      {'id': 8,  'text': 'Navegar pelo aplicativo é simples e intuitivo.'},
      {'id': 9,  'text': 'Eu me senti confiante ao utilizar o aplicativo.'},
      {'id': 10, 'text': 'Não encontrei dificuldades significativas ao usar o aplicativo.'},
    ],
  },
  {
    'title': 'Experiência do Usuário (UX)',
    'icon': Icons.star_outline,
    'questions': [
      {'id': 11, 'text': 'O design do aplicativo é agradável.'},
      {'id': 12, 'text': 'A organização das telas facilita o uso do aplicativo.'},
      {'id': 13, 'text': 'O aplicativo responde rapidamente às ações do usuário.'},
      {'id': 14, 'text': 'O aplicativo é visualmente claro e compreensível.'},
    ],
  },
  {
    'title': 'Qualidade do Conteúdo',
    'icon': Icons.library_books_outlined,
    'questions': [
      {'id': 15, 'text': 'Os vídeos em Libras ajudam na compreensão dos termos apresentados.'},
      {'id': 16, 'text': 'As descrições escritas são claras e fáceis de entender.'},
      {'id': 17, 'text': 'O conteúdo apresentado é relevante para o aprendizado.'},
      {'id': 18, 'text': 'O aplicativo apresenta informações confiáveis.'},
    ],
  },
  {
    'title': 'Aprendizado',
    'icon': Icons.school_outlined,
    'questions': [
      {'id': 19, 'text': 'O aplicativo contribuiu para meu aprendizado de Libras.'},
      {'id': 20, 'text': 'O aplicativo facilitou a compreensão de termos contábeis em Libras.'},
      {'id': 21, 'text': 'O aplicativo pode ser útil como ferramenta de apoio educacional.'},
      {'id': 22, 'text': 'O aplicativo pode ajudar na inclusão de pessoas surdas na área contábil.'},
    ],
  },
  {
    'title': 'Aceitação da Tecnologia (TAM)',
    'icon': Icons.thumb_up_outlined,
    'questions': [
      {'id': 23, 'text': 'O aplicativo é útil para o aprendizado de Libras.'},
      {'id': 24, 'text': 'O aplicativo melhora o acesso ao conhecimento sobre contabilidade em Libras.'},
      {'id': 25, 'text': 'Eu recomendaria este aplicativo para outras pessoas.'},
      {'id': 26, 'text': 'Eu utilizaria este aplicativo novamente no futuro.'},
    ],
  },
  {
    'title': 'Avaliação Geral',
    'icon': Icons.assessment_outlined,
    'questions': [
      {'id': 27, 'text': 'No geral, estou satisfeito com o aplicativo.'},
      {'id': 28, 'text': 'O aplicativo atende às expectativas dos usuários.'},
      {'id': 29, 'text': 'O aplicativo possui potencial para auxiliar no ensino de Libras.'},
    ],
  },
];

// Perguntas por categoria (IDs 30+) — proposta para validação (D-05)
static const Map<String, List<Map<String, dynamic>>> _categoryQuestions = {
  'Estudante': [
    {'id': 30, 'text': 'O aplicativo é útil como complemento aos estudos na área contábil.'},
    {'id': 31, 'text': 'Utilizaria o aplicativo para estudar termos contábeis em Libras.'},
    {'id': 32, 'text': 'O aplicativo facilitaria minha comunicação com colegas surdos.'},
  ],
  'Professor': [
    {'id': 33, 'text': 'Utilizaria o aplicativo como recurso pedagógico em sala de aula.'},
    {'id': 34, 'text': 'O conteúdo está adequado para uso em contexto educacional formal.'},
    {'id': 35, 'text': 'O aplicativo pode contribuir para a inclusão de alunos surdos.'},
  ],
  'Pessoa surda': [
    {'id': 36, 'text': 'Os sinais apresentados correspondem ao que conheço de Libras.'},
    {'id': 37, 'text': 'O aplicativo facilita minha compreensão de termos contábeis.'},
    {'id': 38, 'text': 'O aplicativo poderia me ajudar no mercado de trabalho na área contábil.'},
  ],
  'Intérprete de Libras': [
    {'id': 39, 'text': 'Os sinais apresentados são adequados para uso em contexto profissional.'},
    {'id': 40, 'text': 'O aplicativo pode ser útil para atualização do vocabulário técnico.'},
    {'id': 41, 'text': 'Recomendaria o uso deste aplicativo aos alunos que atendo.'},
  ],
};
```

### Verificação de seção completa (gate de navegação)

```dart
// Source: padrão do EvaluationDialog existente + lógica de validação
bool _isSectionComplete(List<Map<String, dynamic>> questions) {
  return questions.every((q) => _answers.containsKey(q['id'] as int));
}
```

### Payload JSON esperado pela API

```json
{
  "nome": "Ana",
  "idade": 22,
  "categoria": "Estudante",
  "respostas": [
    {"pergunta_id": 4, "valor": 5},
    {"pergunta_id": 5, "valor": 4},
    ...
    {"pergunta_id": 29, "valor": 4},
    {"pergunta_id": 30, "valor": 5},
    {"pergunta_id": 31, "valor": 4},
    {"pergunta_id": 32, "valor": 3}
  ],
  "timestamp": "2026-06-04T15:30:00.000Z"
}
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Pydantic v1 (`class Config`) | Pydantic v2 (`model_config = ConfigDict(...)`) | 2023 | FastAPI 0.100+ usa Pydantic v2 por padrão; sintaxe de configuração mudou |
| `uvicorn main:app` (sem `--host 0.0.0.0`) | `uvicorn main:app --host 0.0.0.0 --port $PORT` | Sempre foi necessário | Railway expõe `$PORT` como env var; sem `0.0.0.0` a app não fica acessível |
| `http` Dart 0.x | `http` Dart 1.x | 2023 | API pública estável; `http.post()` tem assinatura consistente |

**Deprecated/outdated:**
- FastAPI 0.103.x: última versão com suporte a Python 3.7. Não usar — Railway vai rodar Python 3.11 com versão mais recente.
- `psycopg2` (sem `-binary`): requer compilação de bibliotecas C no deploy. Usar sempre `psycopg2-binary` para simplificar o Railway Nixpacks build.

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | python-dotenv >=1.0.0 está disponível no Python 3.11 do Railway | Standard Stack | python-dotenv 1.x requer Python >=3.8; risco baixo |
| A2 | URL do app Vercel é `https://conta-libras.vercel.app` (ou similar) | Pattern 3 (CORS) | CORS pode bloquear chamadas se URL estiver errada — verificar no dashboard Vercel |
| A3 | Perguntas específicas por categoria (IDs 30-41) propostas são adequadas | Code Examples | D-05 exige aprovação do usuário antes de implementar — são placeholder |
| A4 | Railway aceita `Procfile` com `web: uvicorn ...` sem `railway.toml` | Common Pitfalls | Railway pode exigir `railway.toml` com `startCommand` em vez de Procfile |
| A5 | O app Flutter no Vercel já tem URL fixa (não muda a cada deploy) | Pattern 7 | Se URL mudar a cada deploy no Vercel, o CORS precisará de `allow_origins=["*"]` |
| A6 | slopcheck não disponível — todos os pacotes Python marcados [ASSUMED OK] | Package Legitimacy Audit | Risco negligenciável para pacotes com histórico de anos e dezenas de milhões de downloads |

---

## Open Questions (RESOLVED)

1. **Perguntas específicas por categoria (D-05)**
   - O que sabemos: a estrutura foi proposta (IDs 30-41, 3 perguntas por categoria)
   - O que está incerto: se o conteúdo das perguntas propostas está alinhado com os objetivos do TCC
   - RESOLVED: Perguntas propostas (IDs 30-41) incorporadas no Plan 01-04 como constante `_categoryQuestions`. Executor apresenta o wording antes de commitar para validação do usuário (D-05).

2. **URL exata do app no Vercel**
   - O que sabemos: o app está deployado no Vercel
   - O que está incerto: a URL exata (necessária para configurar `allow_origins` no CORS)
   - RESOLVED: Plan 01-02 usa `allow_origins=["*"]` provisoriamente. Plan 01-05 atualiza para a URL real do Vercel após o usuário confirmar durante o setup do deploy.

3. **Deployar API no Railway requer Procfile ou railway.toml?**
   - O que sabemos: Railway suporta ambos; Nixpacks detecta Python automaticamente
   - O que está incerto: qual é o método atual preferido para FastAPI no Railway
   - RESOLVED: Plan 01-02 cria `Procfile` com `web: uvicorn main:app --host 0.0.0.0 --port $PORT` como abordagem conservadora — Railway confirma suporte a Procfile [CITED: docs.railway.com/guides/fastapi].

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | App Flutter | ✓ | 3.19.5 (Dart 3.3.3) | — |
| Python (local) | Desenvolvimento API | ✓ | 3.7.8 (INCOMPATÍVEL com FastAPI moderno) | Usar Python 3.11 via pyenv/conda/WSL, ou testar diretamente no Railway |
| Python (Railway) | Deploy API | ✓ (via Nixpacks) | 3.11 (padrão Railway) | Declarar `runtime.txt` com `python-3.11` |
| pip | Instalar dependências da API | ✓ | 24.0 | — |
| Conta Railway | Deploy da API | [ASSUMED] não verificado | — | Criar conta em railway.com |
| Conta Supabase | Banco PostgreSQL | [ASSUMED] não verificado | — | Criar conta em supabase.com |
| Vercel | Deploy Flutter web | ✓ (app já deployado) | — | — |

**Missing dependencies with no fallback:**
- Python 3.10+ localmente para desenvolvimento/teste da API. Solução: instalar Python 3.11 via python.org ou usar WSL.

**Missing dependencies with fallback:**
- Conta Railway: criar em railway.com (gratuito para projetos TCC). Alternativa: Render.com.
- Conta Supabase: criar em supabase.com (gratuito no free tier). Alternativa: banco PostgreSQL no próprio Railway.

---

## Validation Architecture

> config.json não encontrado — tratando nyquist_validation como habilitado.

### Test Framework

| Property | Value |
|----------|-------|
| Framework Flutter | flutter_test (SDK — já no pubspec.yaml) |
| Framework API Python | Nenhum detectado — Wave 0 deve adicionar `pytest` |
| Config file | Nenhum detectado |
| Quick run command (Flutter) | `flutter test` |
| Quick run command (API) | `pytest api/tests/ -x` |
| Full suite command | `flutter test && pytest api/tests/` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| D-11 | UserManager persiste campo `age` | unit (Flutter) | `flutter test test/user_manager_test.dart` | ❌ Wave 0 |
| D-10 | FeedbackService monta payload correto | unit (Flutter) | `flutter test test/feedback_service_test.dart` | ❌ Wave 0 |
| D-13 | Dialog permanece aberto após erro de envio | widget test (Flutter) | `flutter test test/evaluation_dialog_test.dart` | ❌ Wave 0 |
| D-06 | POST /feedback retorna 201 com payload válido | integration (API) | `pytest api/tests/test_feedback.py -x` | ❌ Wave 0 |
| D-06 | POST /feedback retorna 422 com payload inválido | unit (API) | `pytest api/tests/test_feedback.py::test_invalid -x` | ❌ Wave 0 |

### Wave 0 Gaps

- [ ] `conta_libras_2/test/user_manager_test.dart` — cobre D-11
- [ ] `conta_libras_2/test/feedback_service_test.dart` — cobre D-10
- [ ] `conta_libras_2/test/evaluation_dialog_test.dart` — cobre D-13
- [ ] `api/tests/test_feedback.py` — cobre D-06
- [ ] `api/tests/conftest.py` — fixtures compartilhadas (mock DB connection)
- [ ] Framework install API: `pip install pytest httpx` — pytest não detectado

---

## Security Domain

> TCC sem autenticação (out of scope). ASVS aplicado de forma mínima.

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | não | Out of scope (D-09, D-12 — sem auth) |
| V3 Session Management | não | Sem sessões — API stateless |
| V4 Access Control | não | API pública para TCC |
| V5 Input Validation | sim | Pydantic BaseModel no FastAPI — valida tipos e campos obrigatórios |
| V6 Cryptography | não | Sem dados sensíveis criptografados |

### Known Threat Patterns para este stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Injeção SQL via payload | Tampering | Usar query parametrizada com psycopg2 (`%s` placeholders) — NUNCA f-strings com dados do usuário |
| Spam/flood de submissões | Denial of Service | Out of scope para TCC — D-12 permite múltiplas submissões |
| Exposição da DATABASE_URL | Information Disclosure | DATABASE_URL apenas em variável de ambiente Railway — nunca no código-fonte ou git |
| CORS mal configurado permitindo origens arbitrárias | Spoofing | Usar domínio Vercel específico em `allow_origins` — evitar `["*"]` em produção |

---

## Sources

### Primary (HIGH confidence)
- [pypi.org/project/fastapi](https://pypi.org/project/fastapi/) — versão atual 0.136.3, Python >=3.10
- [pypi.org/project/pydantic](https://pypi.org/project/pydantic/) — versão atual 2.x
- [pypi.org/project/psycopg2-binary](https://pypi.org/project/psycopg2-binary/) — versão 2.9.9
- [pub.dev/packages/http](https://pub.dev/packages/http) — versão 1.6.0 (verificado via curl pub.dev API)
- [fastapi.tiangolo.com/tutorial/cors](https://fastapi.tiangolo.com/tutorial/cors/) — CORSMiddleware
- [docs.flutter.dev/cookbook/networking/send-data](https://docs.flutter.dev/cookbook/networking/send-data) — http.post padrão
- [supabase.com/docs/guides/database/connecting-to-postgres](https://supabase.com/docs/guides/database/connecting-to-postgres) — strings de conexão PostgreSQL

### Secondary (MEDIUM confidence)
- [docs.railway.com/guides/fastapi](https://docs.railway.com/guides/fastapi) — deploy FastAPI no Railway; Hypercorn/startCommand
- Codebase: `evaluation_dialog.dart`, `user_manager.dart`, `first_access_screen.dart`, `pubspec.yaml` — estado atual do app

### Tertiary (LOW confidence)
- WebSearch: Railway Python 3.11 default via Nixpacks — múltiplas fontes concordam, mas não verificado em docs oficiais Railway
- WebSearch: python-dotenv 1.0+ para Python 3.11 — provável, não verificado via docs oficiais

---

## Metadata

**Confidence breakdown:**
- Standard Stack Flutter: HIGH — http 1.6.0 verificado via pub.dev API; dart:convert é SDK built-in
- Standard Stack API: MEDIUM — versões verificadas no PyPI, mas via Python 3.7 local (retorna versões antigas); versões no Railway serão as atuais >=0.110
- Architecture Patterns: HIGH — baseado na leitura direta do código existente + docs oficiais FastAPI e Flutter
- Pitfalls: HIGH — baseado em incompatibilidade de versão verificada (Python 3.7 local vs FastAPI >=0.10 requerendo Python >=3.10)
- Deploy Railway: MEDIUM — documentação oficial lida, mas alguns detalhes (Procfile vs railway.toml) marcados como [ASSUMED]

**Research date:** 2026-06-04
**Valid until:** 2026-07-04 (estável; FastAPI e Flutter http package têm ciclo de release lento para breaking changes)

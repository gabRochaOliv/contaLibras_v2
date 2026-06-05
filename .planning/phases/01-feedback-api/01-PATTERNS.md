# Phase 1: Coleta de Feedbacks e API — Pattern Map

**Mapped:** 2026-06-04
**Files analyzed:** 8 (4 modificados + 4 novos)
**Analogs found:** 6 / 8 (2 sem analog direto — API Python, novos no repo)

---

## File Classification

| Arquivo novo/modificado | Role | Data Flow | Analog mais próximo | Qualidade do match |
|-------------------------|------|-----------|--------------------|--------------------|
| `conta_libras_2/lib/ui/widgets/evaluation_dialog.dart` | component/widget | request-response | si mesmo (expansão) | self-analog (exact) |
| `conta_libras_2/lib/data/managers/user_manager.dart` | manager/store | CRUD (memória) | `theme_manager.dart`, `progress_manager.dart` | exact |
| `conta_libras_2/lib/ui/screens/first_access/first_access_screen.dart` | component/screen | request-response | si mesmo (ajuste pontual) | self-analog (exact) |
| `conta_libras_2/pubspec.yaml` | config | — | si mesmo (adicionar linha) | self-analog (exact) |
| `conta_libras_2/lib/data/services/feedback_service.dart` *(NOVO)* | service | request-response | `user_manager.dart` + `progress_manager.dart` | role-match (singleton ChangeNotifier) |
| `conta_libras_2/lib/core/constants.dart` *(NOVO)* | config/utility | — | `app_colors.dart` (classe utilitária estática) | role-match |
| `api/main.py` *(NOVO)* | controller/route | request-response | sem analog — primeiro arquivo Python do repo | none |
| `api/requirements.txt`, `api/runtime.txt`, `api/Procfile` *(NOVOS)* | config/deploy | — | sem analog | none |

---

## Pattern Assignments

### `conta_libras_2/lib/ui/widgets/evaluation_dialog.dart` (component, request-response)

**Analog:** si mesmo — arquivo será expandido, não substituído.

**Imports pattern** (linhas 1–3):
```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
```
Ao expandir, adicionar imports do FeedbackService e de `package:flutter/foundation.dart` (para `kDebugMode` se necessário):
```dart
import '../../data/services/feedback_service.dart';
```

**State pattern** (linhas 12–18) — manter estrutura de estado local:
```dart
final PageController _pageController = PageController();
int _currentPage = 0;
bool _hasAcceptedTerms = false;
final Map<int, int> _answers = {};  // chave = pergunta_id (IDs do questionario_IHC.md)
```
**IMPORTANTE:** A chave do `_answers` deve ser o `id` global da pergunta (ex: 4, 5, ..., 41), não o índice local da seção. Isso evita o Pitfall 3 de colisão de índices.

**Likert scale reutilizável** (linhas 58–113) — copiar sem alterações:
```dart
Widget _buildLikertScale(int questionIndex) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          int value = index + 1;
          bool isSelected = _answers[questionIndex] == value;
          return GestureDetector(
            onTap: () => _selectAnswer(questionIndex, value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.divider,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, spreadRadius: 2)]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }),
      ),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Discordo\nTotalmente', textAlign: TextAlign.left, style: AppTextStyles.label.copyWith(fontSize: 10)),
          Text('Concordo\nTotalmente', textAlign: TextAlign.right, style: AppTextStyles.label.copyWith(fontSize: 10)),
        ],
      )
    ],
  );
}
```

**TCLE view pattern** (linhas 168–241) — reutilizar `_buildTCLEView()`, `_buildSectionTitle()` e `_buildParagraph()` sem alteração.

**AnimatedContainer / Dialog shell** (linhas 265–316) — manter o shell do Dialog:
```dart
Dialog(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  elevation: 0,
  backgroundColor: Colors.transparent,
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
    // NOVO: usar min(MediaQuery.of(context).size.height * 0.85, 700) para seções longas
    height: _hasAcceptedTerms
        ? MediaQuery.of(context).size.height * 0.85
        : MediaQuery.of(context).size.height * 0.8,
    width: 500,
    constraints: const BoxConstraints(maxHeight: 700),  // era 650 — aumentar para SUS (7 perguntas)
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
    ),
    child: Column( /* ... */ ),
  ),
)
```

**Padrão de submissão — NOVO (substituir o `_nextPage()` final):**
```dart
Future<void> _submit() async {
  final service = FeedbackService();
  await service.submit(_answers);
  if (!mounted) return;
  if (service.hasError) {
    // Mostrar banner de erro — NÃO chamar Navigator.pop() aqui (D-13)
    setState(() { _showError = true; });
  } else {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Obrigado pela sua avaliação e contribuição à pesquisa!',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
```

**Ponto de entrada no app** — `home_screen.dart` linha 136-140 (não modificar):
```dart
showDialog(
  context: context,
  builder: (context) => const EvaluationDialog(),
);
```

---

### `conta_libras_2/lib/data/managers/user_manager.dart` (manager, CRUD em memória)

**Analog:** `conta_libras_2/lib/data/managers/theme_manager.dart` (linhas 1–22) e o próprio `user_manager.dart` (linhas 1–23).

**Singleton ChangeNotifier pattern** — padrão idêntico em todos os managers (linhas 1–11 de `user_manager.dart`):
```dart
import 'package:flutter/foundation.dart';

class UserManager extends ChangeNotifier {
  static final UserManager _instance = UserManager._internal();

  factory UserManager() {
    return _instance;
  }

  UserManager._internal();
```

**Campos e getters** (linhas 12–17) — adicionar campo `age` seguindo o padrão existente:
```dart
// EXISTENTE:
String _userName = 'Estudante';
String _userCategory = 'Estudante de Contábeis';

String get userName => _userName;
String get userCategory => _userCategory;

// ADICIONAR (mesmo padrão):
int _userAge = 0;

int get userAge => _userAge;
```

**setUserData — ajuste de assinatura** (linha 18–22):
```dart
// ANTES (linha 18):
void setUserData(String name, String category) {
  _userName = name;
  _userCategory = category.isNotEmpty ? category : 'Estudante de Contábeis';
  notifyListeners();
}

// DEPOIS (adicionar parâmetro age):
void setUserData(String name, String category, int age) {
  _userName = name;
  _userCategory = category.isNotEmpty ? category : 'Estudante de Contábeis';
  _userAge = age;
  notifyListeners();
}
```

---

### `conta_libras_2/lib/ui/screens/first_access/first_access_screen.dart` (screen/component, request-response)

**Analog:** si mesmo — ajuste pontual em `_submit()` (linha 36–43).

**Ajuste em `_submit()`** (linha 38):
```dart
// ANTES (linha 38):
UserManager().setUserData(_nameController.text.trim(), _selectedCategory ?? '');

// DEPOIS:
UserManager().setUserData(
  _nameController.text.trim(),
  _selectedCategory ?? '',
  int.tryParse(_ageController.text.trim()) ?? 0,
);
```
O campo `_ageController` já existe e já é validado no formulário (linhas 142–171). Nenhuma outra mudança é necessária neste arquivo.

---

### `conta_libras_2/pubspec.yaml` (config)

**Analog:** si mesmo — adicionar uma linha na seção `dependencies`.

**Padrão de dependencies existente** (linhas 30–40):
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  google_fonts: ^6.3.0
  video_player: ^2.9.2
```

**Adição** (inserir após `video_player`):
```yaml
  http: ^1.2.0
```
Após editar, rodar `flutter pub get` no diretório `conta_libras_2/`.

---

### `conta_libras_2/lib/data/services/feedback_service.dart` *(NOVO)* (service, request-response)

**Analog:** `conta_libras_2/lib/data/managers/user_manager.dart` (singleton ChangeNotifier) + `conta_libras_2/lib/data/managers/progress_manager.dart`.

**Imports pattern** — combinar padrão dos managers com imports HTTP:
```dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../managers/user_manager.dart';
import '../../core/constants.dart';
```

**Singleton ChangeNotifier pattern** — copiar estrutura de `user_manager.dart` linhas 1–11:
```dart
class FeedbackService extends ChangeNotifier {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();
```

**Estado exposto** — seguir padrão de getters dos managers:
```dart
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
```

**Core pattern — método submit com try/catch/finally** (sem analog direto; padrão de referência do RESEARCH.md Pattern 1):
```dart
  Future<void> submit(Map<int, int> answers) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
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
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Erro ao enviar avaliação. Verifique sua conexão.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
```

**Padrão de path relativo** — seguir o padrão dos managers (`../../core/...`, `../managers/...`).

---

### `conta_libras_2/lib/core/constants.dart` *(NOVO)* (config/utility)

**Analog:** `conta_libras_2/lib/core/theme/app_colors.dart` — classe utilitária estática com construtor privado.

**Padrão de classe utilitária estática** (de `app_colors.dart` linha 5–6):
```dart
class AppColors {
  AppColors._();   // construtor privado — impede instanciação
  static const Color primary = Color(0xFF1D3557);
  // ...
}
```

**Aplicar o mesmo padrão:**
```dart
import 'package:flutter/foundation.dart';

class AppConstants {
  AppConstants._();  // construtor privado

  static String get apiBaseUrl => kDebugMode
      ? 'http://localhost:8000'
      : 'https://api-conta-libras.railway.app';  // atualizar após deploy Railway
}
```
`kDebugMode` (de `flutter/foundation.dart`) diferencia ambiente local de produção, evitando o Pitfall 5.

---

### `api/main.py` *(NOVO)* (controller/route, request-response)

**Analog:** sem analog — primeiro arquivo Python do repositório.

**Padrão de referência** (RESEARCH.md Pattern 3 — fonte: fastapi.tiangolo.com/tutorial):
```python
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from models import FeedbackPayload
from database import insert_feedback

app = FastAPI(title="ContaLibras Feedback API")

# CORS deve ser adicionado ANTES das rotas (Pitfall 2)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Atualizar com URL Vercel após deploy (Open Question 2)
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

**Padrão de modelos Pydantic** (`api/models.py` — RESEARCH.md Pattern 4):
```python
from pydantic import BaseModel
from typing import List
from datetime import datetime

class Resposta(BaseModel):
    pergunta_id: int
    valor: int  # 1–5

class FeedbackPayload(BaseModel):
    nome: str
    idade: int
    categoria: str
    respostas: List[Resposta]
    timestamp: datetime
```

**Padrão de conexão psycopg2** (`api/database.py` — RESEARCH.md Pattern 5):
```python
import os
import psycopg2
from psycopg2.extras import Json
from dotenv import load_dotenv

load_dotenv()

def get_connection():
    return psycopg2.connect(os.environ["DATABASE_URL"])  # porta 5432 (Pitfall 6)

def insert_feedback(payload):
    conn = get_connection()
    try:
        cur = conn.cursor()
        respostas_json = [r.model_dump() for r in payload.respostas]  # Pydantic v2: model_dump()
        cur.execute(
            "INSERT INTO feedbacks (nome, idade, categoria, respostas, criado_em) VALUES (%s, %s, %s, %s, %s)",
            (payload.nome, payload.idade, payload.categoria, Json(respostas_json), payload.timestamp)
        )
        conn.commit()
    finally:
        conn.close()
```
**Nota:** Pydantic v2 usa `.model_dump()` — o RESEARCH.md Pattern 5 usa `.dict()` (Pydantic v1). Usar `.model_dump()`.

---

### `api/requirements.txt`, `api/runtime.txt`, `api/Procfile` *(NOVOS)* (config/deploy)

**Analog:** sem analog — sem arquivos Python/deploy no repo.

**requirements.txt** (RESEARCH.md Standard Stack):
```
fastapi>=0.110.0,<1.0.0
uvicorn[standard]>=0.29.0
pydantic>=2.6.0,<3.0.0
psycopg2-binary>=2.9.9
python-dotenv>=1.0.0
```

**runtime.txt** (declarar Python explícito — evita Python 3.7 local, Pitfall 1):
```
python-3.11
```

**Procfile** (RESEARCH.md Open Question 3 — Procfile é o fallback seguro):
```
web: uvicorn main:app --host 0.0.0.0 --port $PORT
```
O `--host 0.0.0.0` é obrigatório no Railway; sem ele a app não fica acessível externamente.

---

## Shared Patterns

### Singleton ChangeNotifier
**Fonte:** `conta_libras_2/lib/data/managers/user_manager.dart` (linhas 1–11), `theme_manager.dart` (linhas 1–10), `progress_manager.dart` (linhas 1–11)
**Aplicar em:** `feedback_service.dart`
```dart
import 'package:flutter/foundation.dart';

class NomeDaClasse extends ChangeNotifier {
  static final NomeDaClasse _instance = NomeDaClasse._internal();
  factory NomeDaClasse() => _instance;
  NomeDaClasse._internal();
  // campos, getters, métodos públicos...
  // sempre chamar notifyListeners() após mutações de estado
}
```

### Import path relativo (Flutter)
**Fonte:** `conta_libras_2/lib/ui/screens/first_access/first_access_screen.dart` (linhas 2–6)
**Aplicar em:** todos os novos arquivos Flutter
```dart
// Padrão de caminho relativo — sem path aliases, sem barril exports
import '../../../core/theme/app_colors.dart';
import '../../../data/managers/user_manager.dart';
```
O projeto não usa `package:conta_libras_2/...` nem barrel imports — usar sempre caminhos relativos.

### AppColors + AppTextStyles (temas)
**Fonte:** `conta_libras_2/lib/core/theme/app_colors.dart`, `app_text_styles.dart`
**Aplicar em:** toda UI nova no `evaluation_dialog.dart`
```dart
// Cores
AppColors.primary     // Color(0xFF1D3557) — azul escuro
AppColors.secondary   // Color(0xFF457B9D) — azul claro
AppColors.surface     // branco / dark card
AppColors.divider     // borda/separador
AppColors.textSecondary

// Botão primário
ElevatedButton.styleFrom(
  backgroundColor: AppColors.primary,
  foregroundColor: Colors.white,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
)
```

### AnimatedContainer para transições no Dialog
**Fonte:** `conta_libras_2/lib/ui/widgets/evaluation_dialog.dart` (linhas 270–283)
**Aplicar em:** shell do `EvaluationDialog` expandido
```dart
AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  // usar height dinâmica — não valor fixo
)
```

### SnackBar de feedback ao usuário
**Fonte:** `conta_libras_2/lib/ui/widgets/evaluation_dialog.dart` (linhas 35–44)
**Aplicar em:** fluxo de sucesso do `EvaluationDialog` após `FeedbackService.submit()`
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('...', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
    backgroundColor: AppColors.primary,
    behavior: SnackBarBehavior.floating,
  ),
);
```

### Validação de formulário Flutter (Form + GlobalKey)
**Fonte:** `conta_libras_2/lib/ui/screens/first_access/first_access_screen.dart` (linhas 17, 37, 89)
**Aplicar em:** qualquer validação de gate no `EvaluationDialog` (verificar seção completa antes de avançar)
```dart
// Padrão de gate sem Form — usar verificação manual:
bool _isSectionComplete(List<Map<String, dynamic>> questions) {
  return questions.every((q) => _answers.containsKey(q['id'] as int));
}
// Só habilitar botão "Próxima seção" quando _isSectionComplete() == true
```

### Query parametrizada psycopg2 (segurança SQL)
**Fonte:** RESEARCH.md Security Domain — anti-padrão identificado
**Aplicar em:** `api/database.py`
```python
# CORRETO — placeholders %s
cur.execute("INSERT INTO feedbacks (...) VALUES (%s, %s, %s, %s, %s)", (val1, val2, ...))

# PROIBIDO — f-string com dados do usuário
cur.execute(f"INSERT INTO feedbacks (...) VALUES ('{payload.nome}', ...)")  # SQL injection
```

---

## No Analog Found

| Arquivo | Role | Data Flow | Motivo |
|---------|------|-----------|--------|
| `api/main.py` | controller/route | request-response | Primeiro arquivo Python do repo — sem analog Flask/FastAPI existente |
| `api/requirements.txt` | config/deploy | — | Sem arquivo Python de dependências no repo |
| `api/runtime.txt` | config/deploy | — | Sem configuração de runtime Python no repo |
| `api/Procfile` | config/deploy | — | Sem arquivo de deploy no repo |
| `api/models.py` | model/schema | transform | Sem modelo Pydantic no repo — usar padrão de RESEARCH.md Pattern 4 |
| `api/database.py` | service | CRUD | Sem camada de acesso a banco no repo — usar padrão de RESEARCH.md Pattern 5 |

Para todos esses arquivos, o planner deve usar os padrões de código do RESEARCH.md (Patterns 3–6) como referência primária.

---

## Anti-Patterns Identificados no Codebase

| Anti-pattern | Onde está | Risco na Fase 1 | Mitigação |
|---|---|---|---|
| `_selectAnswer()` com autonext imediato (linhas 48–56 de `evaluation_dialog.dart`) | `EvaluationDialog` | Com seções multi-pergunta, o autonext navegaria de seção automaticamente após cada resposta | Remover o autonext. Cada clique só registra a resposta; navegação só via botão "Próxima Seção" |
| `height: _hasAcceptedTerms ? 380 : ...` (linha 274) | `EvaluationDialog` | 380px é insuficiente para seções com 7 perguntas (SUS) — overflow de layout | Substituir por `MediaQuery.of(context).size.height * 0.85` com `maxHeight: 700` |
| `setUserData(String name, String category)` sem `age` (linha 18) | `UserManager` | Idade coletada no formulário é descartada — payload envia `userAge == 0` | Adicionar parâmetro `int age` à assinatura (D-11) |

---

## Metadata

**Escopo de busca de analogs:** `conta_libras_2/lib/` (todos os 21 arquivos `.dart`)
**Arquivos lidos:** 9 (evaluation_dialog.dart, user_manager.dart, first_access_screen.dart, pubspec.yaml, theme_manager.dart, progress_manager.dart, app_colors.dart, home_screen.dart, 01-CONTEXT.md, 01-RESEARCH.md)
**Data de mapeamento:** 2026-06-04

---
plan: 01-04
status: complete
wave: 3
depends_on: [01-01, 01-03]
---

# Resumo — Plano 01-04: EvaluationDialog

## O que foi feito
- `evaluation_dialog.dart` completamente reescrito: 6 seções comuns (IDs 4–29) + seção por categoria (IDs 30–41)
- Navegação por botões com gate de seção completa (Próximo desabilitado até todas as perguntas respondidas)
- Submissão via `FeedbackService` com loading state (`CircularProgressIndicator`) e error banner com retry
- TCLE preservado sem alterações
- Autonext (`Future.delayed`) removido
- Semântica de acessibilidade: `Semantics` em Likert, headers de seção, banner de erro com `liveRegion: true`
- Adicionados parâmetros opcionais para testabilidade (`initialPage`, `initialAnswers`, `initialHasAcceptedTerms`, `submitHandler`)
- Compatibilidade mantida com `const EvaluationDialog()` em `home_screen.dart`
- Criado `test/evaluation_dialog_test.dart` com 5 testes

## Verificações
- `flutter analyze lib/ui/widgets/evaluation_dialog.dart`: No issues found
- `flutter test test/evaluation_dialog_test.dart`: 5/5 testes passaram
- `grep Future.delayed`: ausente (confirmado)
- `grep _sections`: presente
- `grep _submit`: presente
- `grep "Tentar novamente"`: presente
- `grep NeverScrollableScrollPhysics`: presente
- `flutter analyze lib/ui/screens/home/home_screen.dart`: No issues found

## Notas
- Os 4 `info` iniciais de `prefer_const_constructors` foram corrigidos (TextStyle inline removido, const adicionado em AlwaysStoppedAnimation, BorderSide e Text)
- `UserManager().userCategory` usa valor padrão `'Estudante de Contábeis'` que não consta nas chaves de `_categoryQuestions`, portanto a seção de categoria não aparece para usuários sem categoria definida — comportamento correto e esperado

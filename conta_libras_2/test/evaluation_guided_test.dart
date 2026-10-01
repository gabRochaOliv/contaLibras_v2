import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:conta_libras_2/ui/widgets/evaluation_dialog.dart';

Future<void> _pumpDialog(WidgetTester tester, {double height = 700}) async {
  tester.view.physicalSize = Size(390, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const MaterialApp(
    home: Scaffold(body: EvaluationDialog(initialHasAcceptedTerms: true)),
  ));
  await tester.pump();
}

double _scrollOffset(WidgetTester tester) {
  final scrollable = find.byType(Scrollable).evaluate().map((e) {
    return (e as StatefulElement).state as ScrollableState;
  }).firstWhere((s) => s.axisDirection == AxisDirection.down);
  return scrollable.position.pixels;
}

/// Trecho do texto de cada pergunta da primeira seção, para achar o card.
const _questionText = {
  1: 'Libras/Português',
  2: 'transição entre os módulos',
  3: 'Cores, contraste',
  4: 'minimiza ações acidentais',
};

Finder _card(int n) => find
    .ancestor(
      of: find.textContaining(_questionText[n]!),
      matching: find.byType(AnimatedContainer),
    )
    .first; // o card mais próximo, não o container do diálogo

/// Círculo da nota [value] no card da pergunta [n].
Finder _circle(int n, int value) =>
    find.descendant(of: _card(n), matching: find.text('$value'));

/// Rola até o círculo (como o usuário faria), toca e devolve quanto a tela
/// rolou SOZINHA entre o toque e o fim das animações.
Future<double> _answer(WidgetTester tester, int n, int value) async {
  final circle = _circle(n, value);
  await tester.ensureVisible(circle);
  await tester.pumpAndSettle();
  final before = _scrollOffset(tester);
  await tester.tap(circle);
  await tester.pumpAndSettle();
  return _scrollOffset(tester) - before;
}

void main() {
  testWidgets('mostra a dica de como responder', (tester) async {
    await _pumpDialog(tester);
    expect(find.textContaining('Toque em uma nota de 1 a 5'), findsOneWidget);
  });

  testWidgets('responder uma pergunta rola para a próxima', (tester) async {
    await _pumpDialog(tester);

    final rolou = await _answer(tester, 1, 4);

    expect(rolou, greaterThan(0), reason: 'deve rolar até a pergunta 2');
    expect(
        find.textContaining(_questionText[2]!).hitTestable(), findsOneWidget);
  });

  testWidgets('após a última pergunta, os botões ficam visíveis',
      (tester) async {
    // Tela baixa: ao responder a última pergunta os botões estão fora da vista.
    await _pumpDialog(tester, height: 520);
    for (var n = 1; n <= 3; n++) {
      await _answer(tester, n, 5);
    }
    await _answer(tester, 4, 5);

    final next = find.widgetWithText(ElevatedButton, 'Próximo');
    expect(next.hitTestable(), findsOneWidget);
    expect(tester.widget<ElevatedButton>(next).onPressed, isNotNull);
  });

  testWidgets('corrigir uma nota já dada não faz a tela pular', (tester) async {
    await _pumpDialog(tester);
    await _answer(tester, 1, 4);

    // Volta à pergunta 1 e muda a nota.
    final rolou = await _answer(tester, 1, 2);

    expect(rolou, 0);
  });

  testWidgets('pular uma pergunta segue para a seguinte, não volta',
      (tester) async {
    await _pumpDialog(tester, height: 520);
    await _answer(tester, 1, 3);
    // Pula a 2 e responde a 3: deve descer para a 4, não subir para a 2.
    final rolou = await _answer(tester, 3, 3);
    expect(rolou, greaterThanOrEqualTo(0), reason: 'não deve subir para a 2');
    expect(
        find.textContaining(_questionText[4]!).hitTestable(), findsOneWidget);
  });
}

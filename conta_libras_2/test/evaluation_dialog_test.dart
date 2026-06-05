import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:conta_libras_2/ui/widgets/evaluation_dialog.dart';

Map<int, int> get _allCommonAnswers =>
    Map.fromEntries(List.generate(26, (i) => MapEntry(4 + i, 5)));

Widget _wrapInApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

Widget _wrapInDialog(EvaluationDialog dialog) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => showDialog(
            context: context,
            builder: (_) => dialog,
          ),
          child: const Text('Open'),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('gate_disabled: botão Próximo desabilitado sem respostas',
      (tester) async {
    await tester.pumpWidget(_wrapInApp(const EvaluationDialog(
      initialHasAcceptedTerms: true,
      initialPage: 0,
    )));
    await tester.pump();

    final nextButton = find.widgetWithText(ElevatedButton, 'Próximo');
    expect(nextButton, findsOneWidget);
    final button = tester.widget<ElevatedButton>(nextButton);
    expect(button.onPressed, isNull,
        reason: 'Botão deve estar desabilitado sem respostas');
  });

  testWidgets('gate_enabled: botão habilitado após responder seção SUS',
      (tester) async {
    const answers = {4: 5, 5: 4, 6: 3, 7: 5, 8: 4, 9: 3, 10: 5};
    await tester.pumpWidget(_wrapInApp(const EvaluationDialog(
      initialHasAcceptedTerms: true,
      initialPage: 0,
      initialAnswers: answers,
    )));
    await tester.pump();

    final nextButton = find.widgetWithText(ElevatedButton, 'Próximo');
    expect(nextButton, findsOneWidget);
    final button = tester.widget<ElevatedButton>(nextButton);
    expect(button.onPressed, isNotNull,
        reason: 'Botão deve estar habilitado com todas as respostas');
  });

  testWidgets('error_banner: exibe mensagem após falha no envio',
      (tester) async {
    await tester.pumpWidget(_wrapInApp(EvaluationDialog(
      initialHasAcceptedTerms: true,
      initialPage: 5,
      initialAnswers: _allCommonAnswers,
      submitHandler: (_) async => false,
    )));
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Enviar Avaliação'));
    await tester.pumpAndSettle();

    expect(find.text('Não foi possível enviar sua avaliação.'), findsOneWidget);
  });

  testWidgets('dialog_stays_open: dialog permanece aberto em caso de erro',
      (tester) async {
    await tester.pumpWidget(_wrapInApp(EvaluationDialog(
      initialHasAcceptedTerms: true,
      initialPage: 5,
      initialAnswers: _allCommonAnswers,
      submitHandler: (_) async => false,
    )));
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Enviar Avaliação'));
    await tester.pumpAndSettle();

    expect(find.byType(EvaluationDialog), findsOneWidget,
        reason: 'Dialog deve permanecer aberto em caso de erro');
  });

  testWidgets('success_closes_dialog: fecha dialog após envio com sucesso',
      (tester) async {
    await tester.pumpWidget(_wrapInDialog(EvaluationDialog(
      initialHasAcceptedTerms: true,
      initialPage: 5,
      initialAnswers: _allCommonAnswers,
      submitHandler: (_) async => true,
    )));
    await tester.pump();

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(EvaluationDialog), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Enviar Avaliação'));
    await tester.pumpAndSettle();

    expect(find.byType(EvaluationDialog), findsNothing,
        reason: 'Dialog deve fechar após envio bem-sucedido');
  });
}

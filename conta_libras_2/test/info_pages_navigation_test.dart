import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:conta_libras_2/ui/screens/about/how_to_use_screen.dart';
import 'package:conta_libras_2/ui/screens/home/home_screen.dart';
import 'package:conta_libras_2/ui/screens/main/main_screen.dart';

Future<void> _pumpMain(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const MaterialApp(home: MainScreen()));
  await tester.pump();
}

void main() {
  testWidgets('mobile: "Como usar" abre mantendo a barra inferior',
      (tester) async {
    await _pumpMain(tester, const Size(390, 844));

    await tester.tap(find.text('Como usar'));
    await tester.pumpAndSettle();

    expect(find.text('Um guia rápido das funções do ContaLibras.'),
        findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // A MainScreen mantém as abas montadas por baixo; rola só o guia.
    final guia = find
        .descendant(
            of: find.byType(HowToUseScreen), matching: find.byType(Scrollable))
        .first;

    // Abas de um termo destacadas no passo "Dentro de um termo".
    for (final aba in ['Vídeo', 'Conteúdo', 'Visual']) {
      await tester.scrollUntilVisible(find.textContaining('$aba: '), 200,
          scrollable: guia);
      expect(find.textContaining('$aba: '), findsOneWidget);
    }
    await tester.scrollUntilVisible(find.textContaining('2 a 3 minutos'), 200,
        scrollable: guia);
    // O crédito do desenvolvedor não aparece no guia.
    expect(
      find.descendant(
        of: find.byType(HowToUseScreen),
        matching: find.text('Desenvolvido por Gabriel Rocha'),
      ),
      findsNothing,
    );

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    expect(
        find.text('Um guia rápido das funções do ContaLibras.'), findsNothing);
  });

  testWidgets('mobile: "Sobre o App" abre do Perfil e fecha ao trocar de aba',
      (tester) async {
    await _pumpMain(tester, const Size(390, 844));

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sobre o App'));
    await tester.pumpAndSettle();

    expect(find.text('Versão 2.0.0'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    await tester.tap(find.text('Início'));
    await tester.pumpAndSettle();
    expect(find.text('Versão 2.0.0'), findsNothing);
  });

  testWidgets('desktop: "Sobre o App" mantém a sidebar', (tester) async {
    await _pumpMain(tester, const Size(1280, 800));

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sobre o App'));
    await tester.pumpAndSettle();

    expect(find.text('Versão 2.0.0'), findsOneWidget);
    // Itens da sidebar continuam visíveis e clicáveis.
    expect(find.text('Dicionário'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Início volta ao topo ao retornar de outra aba', (tester) async {
    await _pumpMain(tester, const Size(390, 600));

    final homeScroll = find
        .descendant(
            of: find.byType(HomeScreen), matching: find.byType(Scrollable))
        .first;
    ScrollPosition position() =>
        tester.state<ScrollableState>(homeScroll).position;

    await tester.drag(homeScroll, const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(position().pixels, greaterThan(0), reason: 'pré-condição');

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Início'));
    await tester.pumpAndSettle();

    expect(position().pixels, 0);
  });
}

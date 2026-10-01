import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:conta_libras_2/data/managers/theme_manager.dart';
import 'package:conta_libras_2/ui/screens/about/about_screen.dart';

void main() {
  tearDown(() {
    if (ThemeManager().isDarkMode) ThemeManager().toggleTheme();
  });

  for (final dark in [false, true]) {
    testWidgets('Sobre o App renderiza no celular (modo escuro: $dark)',
        (tester) async {
      if (dark) ThemeManager().toggleTheme();
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MaterialApp(home: AboutScreen()));
      await tester.pump();

      expect(find.text('O que é o ContaLibras'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Projeto acadêmico'), 200);
      expect(find.text('Projeto acadêmico'), findsOneWidget);
      await tester.scrollUntilVisible(
          find.text('Desenvolvido por Gabriel Rocha'), 200);
      expect(find.text('Desenvolvido por Gabriel Rocha'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

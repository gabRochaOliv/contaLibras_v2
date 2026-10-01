import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:conta_libras_2/core/theme/app_colors.dart';
import 'package:conta_libras_2/core/theme/theme_refresh_scope.dart';
import 'package:conta_libras_2/data/managers/theme_manager.dart';

/// Widget `const` que lê a cor direto de AppColors, sem depender do Theme —
/// o mesmo padrão da sidebar que ficava presa no modo claro.
class _ColorProbe extends StatelessWidget {
  const _ColorProbe();

  @override
  Widget build(BuildContext context) {
    return Container(key: const Key('probe'), color: AppColors.surface);
  }
}

class _StatefulHolder extends StatefulWidget {
  const _StatefulHolder();

  @override
  State<_StatefulHolder> createState() => _StatefulHolderState();
}

class _StatefulHolderState extends State<_StatefulHolder> {
  int counter = 0;

  @override
  Widget build(BuildContext context) => const _ColorProbe();
}

Color _probeColor(WidgetTester tester) =>
    tester.widget<Container>(find.byKey(const Key('probe'))).color!;

void main() {
  tearDown(() {
    if (ThemeManager().isDarkMode) ThemeManager().toggleTheme();
  });

  testWidgets('widget const que usa AppColors troca de cor junto com o tema',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ThemeRefreshScope(child: _StatefulHolder())),
    );
    expect(_probeColor(tester), AppPalette.light.surface);

    ThemeManager().toggleTheme();
    await tester.pump();
    expect(_probeColor(tester), AppPalette.dark.surface);

    ThemeManager().toggleTheme();
    await tester.pump();
    expect(_probeColor(tester), AppPalette.light.surface);
  });

  testWidgets('troca de tema não perde o estado dos widgets', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ThemeRefreshScope(child: _StatefulHolder())),
    );
    tester.state<_StatefulHolderState>(find.byType(_StatefulHolder)).counter =
        7;

    ThemeManager().toggleTheme();
    await tester.pump();

    expect(
      tester.state<_StatefulHolderState>(find.byType(_StatefulHolder)).counter,
      7,
    );
  });
}

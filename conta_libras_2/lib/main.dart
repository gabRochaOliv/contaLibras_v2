import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'ui/screens/splash/splash_screen.dart';
import 'data/managers/theme_manager.dart';

void main() {
  runApp(const ContaLibrasApp());
}

class ContaLibrasApp extends StatelessWidget {
  const ContaLibrasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeManager(),
      builder: (context, child) {
        return MaterialApp(
          title: 'ContaLibras',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeManager().themeMode,
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
        );
      },
    );
  }
}

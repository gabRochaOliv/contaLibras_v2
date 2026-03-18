import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'ui/screens/splash/splash_screen.dart';

void main() {
  runApp(const ContaLibrasApp());
}

class ContaLibrasApp extends StatelessWidget {
  const ContaLibrasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ContaLibras',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

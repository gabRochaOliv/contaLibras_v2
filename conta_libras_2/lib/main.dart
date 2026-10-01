import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_refresh_scope.dart';
import 'core/app_messenger.dart';
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
          scaffoldMessengerKey: appMessengerKey,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeManager().themeMode,
          // Troca instantânea: as cores lidas via AppColors mudam no mesmo
          // frame, então uma transição animada do Theme deixaria partes da
          // tela em modos diferentes durante a animação.
          themeAnimationDuration: Duration.zero,
          debugShowCheckedModeBanner: false,
          builder: (context, child) => ThemeRefreshScope(child: child!),
          home: const SplashScreen(),
        );
      },
    );
  }
}

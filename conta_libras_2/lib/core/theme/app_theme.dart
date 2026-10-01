import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _build(AppPalette.light, Brightness.light);

  static ThemeData get darkTheme => _build(AppPalette.dark, Brightness.dark);

  // Os dois temas saem da mesma função e usam a paleta explícita de cada
  // modo, para nunca herdarem cores do modo que está ativo no momento.
  static ThemeData _build(AppPalette p, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme.fromSeed(
      brightness: brightness,
      seedColor: AppColors.primary,
      // No escuro, `primary` é usado pelos componentes padrão do Material
      // (Switch, TextButton, cursor, foco) como cor de primeiro plano, então
      // precisa ser a variante clara legível sobre fundo escuro.
      primary: p.primaryFg,
      onPrimary: isDark ? const Color(0xFF10243A) : Colors.white,
      secondary: p.secondaryFg,
      error: p.accentFg,
      surface: p.surface,
      onSurface: p.textPrimary,
      onSurfaceVariant: p.textSecondary,
      outline: p.border,
      outlineVariant: p.divider,
    );

    TextStyle withColor(TextStyle s, Color c) => s.copyWith(color: c);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      cardColor: p.surface,
      dividerColor: p.divider,
      dividerTheme: DividerThemeData(color: p.divider),
      iconTheme: IconThemeData(color: p.textSecondary),
      textTheme: GoogleFonts.interTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ).copyWith(
        displayLarge: withColor(AppTextStyles.heading1, p.textPrimary),
        headlineMedium: withColor(AppTextStyles.heading2, p.textPrimary),
        titleLarge: withColor(AppTextStyles.heading3, p.textPrimary),
        bodyLarge: withColor(AppTextStyles.bodyLarge, p.textPrimary),
        bodyMedium: withColor(AppTextStyles.bodyMedium, p.textSecondary),
        labelSmall: withColor(AppTextStyles.label, p.textSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: p.textPrimary),
        titleTextStyle: withColor(AppTextStyles.heading2, p.textPrimary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: p.surface,
        selectedItemColor: p.primaryFg,
        unselectedItemColor: p.textSecondary,
        selectedLabelStyle: AppTextStyles.label.copyWith(
          color: p.primaryFg,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
        unselectedLabelStyle:
            AppTextStyles.label.copyWith(color: p.textSecondary, fontSize: 11),
        selectedIconTheme: const IconThemeData(size: 22),
        unselectedIconTheme: const IconThemeData(size: 22),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardTheme(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(isDark ? 0.5 : 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: withColor(AppTextStyles.heading3, p.textPrimary),
        contentTextStyle: withColor(AppTextStyles.bodyMedium, p.textPrimary),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.primaryFg,
        textColor: p.textPrimary,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) =>
            states.contains(MaterialState.selected)
                ? Colors.white
                : p.textSecondary),
        trackColor: MaterialStateProperty.resolveWith((states) =>
            states.contains(MaterialState.selected) ? p.action : p.divider),
        trackOutlineColor: MaterialStateProperty.resolveWith((states) =>
            states.contains(MaterialState.selected)
                ? Colors.transparent
                : p.border),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: p.textSecondary),
        labelStyle: TextStyle(color: p.textSecondary),
        prefixIconColor: p.textSecondary,
      ),
      textSelectionTheme: TextSelectionThemeData(cursorColor: p.primaryFg),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.primaryFg),
    );
  }
}

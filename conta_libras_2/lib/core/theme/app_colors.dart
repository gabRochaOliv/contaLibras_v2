import 'package:flutter/material.dart';

import '../../data/managers/theme_manager.dart';

/// Paleta de um modo (claro ou escuro).
///
/// Todos os pares texto/fundo foram verificados contra o WCAG 2.1 AA:
/// texto >= 4.5:1 e componentes de interface (bordas, ícones) >= 3:1,
/// tanto sobre [background] quanto sobre [surface].
class AppPalette {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.divider,
    required this.border,
    required this.primaryFg,
    required this.secondaryFg,
    required this.accentFg,
    required this.warningFg,
    required this.highlight,
    required this.action,
    required this.errorContainer,
    required this.errorBorder,
    required this.errorFg,
  });

  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;

  /// Separadores decorativos (sem exigência de contraste).
  final Color divider;

  /// Contorno de componentes interativos (>= 3:1 sobre o fundo).
  final Color border;

  /// Cor da marca para texto/ícone sobre background/surface.
  final Color primaryFg;
  final Color secondaryFg;
  final Color accentFg;
  final Color warningFg;

  /// Ícones de destaque (estrela, troféu, selo de visitado).
  final Color highlight;

  /// Fundo de botões preenchidos e itens selecionados; texto em branco.
  final Color action;

  final Color errorContainer;
  final Color errorBorder;
  final Color errorFg;

  static const light = AppPalette(
    background: Color(0xFFF8F9FA),
    surface: Colors.white,
    textPrimary: Color(0xFF2B2D42), // 13.9:1 sobre branco
    textSecondary: Color(0xFF5C677D), // 5.7:1 (antes #8D99AE = 2.9:1)
    divider: Color(0xFFE5E5E5),
    border: Color(0xFF8A94A6), // 3.1:1
    primaryFg: Color(0xFF1D3557), // 12.4:1
    secondaryFg: Color(0xFF35667F), // 6.3:1
    accentFg: Color(0xFFC62834), // 5.6:1 (antes #E63946 = 4.2:1)
    warningFg: Color(0xFF8A5300), // 5.6:1
    highlight: Color(0xFFB37400), // 3.9:1
    action: Color(0xFF1D3557), // branco sobre ele: 12.4:1
    errorContainer: Color(0xFFFDECEA),
    errorBorder: Color(0xFFF2B8B5),
    errorFg: Color(0xFFB3261E), // 5.7:1 sobre errorContainer
  );

  static const dark = AppPalette(
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    // Branco puro sobre preto causa "halo" (halation); off-white é mais
    // confortável para leitura prolongada.
    textPrimary: Color(0xFFE8EAED), // 13.8:1 sobre surface
    textSecondary: Color(0xFFBDBDBD), // 8.9:1
    divider: Color(0xFF333333),
    border: Color(0xFF6B6B6B), // 3.1:1
    primaryFg: Color(0xFFA8C7E6), // 9.5:1 (antes #1D3557 = 1.4:1)
    secondaryFg: Color(0xFF8EC3E6), // 8.8:1
    accentFg: Color(0xFFFF7A82), // 6.6:1
    warningFg: Color(0xFFFFC94D), // 10.9:1
    highlight: Color(0xFFFFC94D),
    action: Color(0xFF3D74A6), // branco sobre ele: 4.9:1; borda 3.4:1
    errorContainer: Color(0xFF3A1F1F),
    errorBorder: Color(0xFF7A3B3B),
    errorFg: Color(0xFFFFB4AB), // 8.9:1 sobre errorContainer
  );
}

class AppColors {
  AppColors._();

  // Cores de marca fixas. Use-as apenas como FUNDO (ex.: splash, avatar,
  // card "Termo do Dia") com texto branco por cima. Para texto e ícones
  // sobre o fundo da tela use os getters adaptativos (*Fg) abaixo.
  static const Color primary = Color(0xFF1D3557); // Deep Blue
  static const Color secondary = Color(0xFF457B9D); // Lighter Blue
  static const Color accent = Color(0xFFE63946); // Red Accent

  static AppPalette get palette =>
      ThemeManager().isDarkMode ? AppPalette.dark : AppPalette.light;

  static Color get background => palette.background;
  static Color get surface => palette.surface;
  static Color get textPrimary => palette.textPrimary;
  static Color get textSecondary => palette.textSecondary;
  static Color get divider => palette.divider;
  static Color get border => palette.border;
  static Color get primaryFg => palette.primaryFg;
  static Color get secondaryFg => palette.secondaryFg;
  static Color get accentFg => palette.accentFg;
  static Color get warningFg => palette.warningFg;
  static Color get highlight => palette.highlight;
  static Color get action => palette.action;
  static Color get errorContainer => palette.errorContainer;
  static Color get errorBorder => palette.errorBorder;
  static Color get errorFg => palette.errorFg;
}

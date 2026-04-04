import 'package:flutter/material.dart';

import '../../data/managers/theme_manager.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1D3557); // Deep Blue / Premium Educational
  static const Color secondary = Color(0xFF457B9D); // Lighter Blue
  static const Color accent = Color(0xFFE63946); // Red Accent
  
  static Color get background => ThemeManager().isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FA); // Off white
  static Color get surface => ThemeManager().isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  static Color get textPrimary => ThemeManager().isDarkMode ? Colors.white : const Color(0xFF2B2D42);
  static Color get textSecondary => ThemeManager().isDarkMode ? Colors.grey.shade400 : const Color(0xFF8D99AE);
  static Color get divider => ThemeManager().isDarkMode ? Colors.grey.shade800 : const Color(0xFFE5E5E5);
}

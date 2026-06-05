import 'package:flutter/foundation.dart';

class AppConstants {
  AppConstants._();

  static String get apiBaseUrl => kDebugMode
      ? 'http://localhost:8000'
      : 'https://api-conta-libras.railway.app';
}

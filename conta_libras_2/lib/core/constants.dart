import 'package:flutter/foundation.dart';

class AppConstants {
  AppConstants._();

  static String get apiBaseUrl => kDebugMode
      ? 'http://localhost:8000'
      : 'https://contalibrasv2-production.up.railway.app';
}

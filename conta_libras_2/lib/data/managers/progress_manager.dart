import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../mock/mock_dictionary_repository.dart';

class ProgressManager extends ChangeNotifier {
  static final ProgressManager _instance = ProgressManager._internal();

  factory ProgressManager() {
    return _instance;
  }

  ProgressManager._internal();

  final Set<String> _viewedTermIds = {};

  String? _userId;

  static const _keyPrefix = 'contalibras_viewed_terms_';
  static const _timeout = Duration(seconds: 4);

  int get totalTerms => MockDictionaryRepository.terms.length;
  int get viewedCount => _viewedTermIds.length;
  double get progressRatio => totalTerms == 0 ? 0.0 : viewedCount / totalTerms;

  Set<String> get viewedTermIds => Set.unmodifiable(_viewedTermIds);

  bool isViewed(String termId) => _viewedTermIds.contains(termId);

  void markAsViewed(String termId) {
    if (_viewedTermIds.add(termId)) {
      notifyListeners();
      _persist();
    }
  }

  Future<void> loadForUser(String userId) async {
    _userId = userId;
    _viewedTermIds.clear();
    try {
      final prefs = await SharedPreferences.getInstance().timeout(_timeout);
      final raw = prefs.getString('$_keyPrefix$userId');
      if (raw != null) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _viewedTermIds.addAll(decoded.map((e) => e.toString()));
      }
    } catch (e) {
      debugPrint('[ProgressManager] falha ao carregar progresso: $e');
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance().timeout(_timeout);
      await prefs.setString(
          '$_keyPrefix$userId', jsonEncode(_viewedTermIds.toList()));
    } catch (e) {
      debugPrint('[ProgressManager] falha ao salvar progresso: $e');
    }
  }

  void clear() {
    _userId = null;
    _viewedTermIds.clear();
    notifyListeners();
  }
}

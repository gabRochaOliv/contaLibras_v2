import 'package:flutter/foundation.dart';
import '../mock/mock_dictionary_repository.dart';

class ProgressManager extends ChangeNotifier {
  static final ProgressManager _instance = ProgressManager._internal();

  factory ProgressManager() {
    return _instance;
  }

  ProgressManager._internal();

  final Set<String> _viewedTermIds = {};

  int get totalTerms => MockDictionaryRepository.terms.length;
  int get viewedCount => _viewedTermIds.length;
  double get progressRatio => totalTerms == 0 ? 0.0 : viewedCount / totalTerms;

  void markAsViewed(String termId) {
    if (!_viewedTermIds.contains(termId)) {
      _viewedTermIds.add(termId);
      notifyListeners();
    }
  }
}

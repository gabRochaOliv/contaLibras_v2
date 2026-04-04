import 'package:flutter/foundation.dart';
import '../models/term_model.dart';

class FavoritesManager extends ChangeNotifier {
  static final FavoritesManager _instance = FavoritesManager._internal();

  factory FavoritesManager() {
    return _instance;
  }

  FavoritesManager._internal();

  final List<TermModel> _favorites = [];

  List<TermModel> get favorites => List.unmodifiable(_favorites);

  bool isFavorite(String termId) {
    return _favorites.any((term) => term.id == termId);
  }

  void toggleFavorite(TermModel term) {
    if (isFavorite(term.id)) {
      _favorites.removeWhere((t) => t.id == term.id);
    } else {
      _favorites.add(term);
    }
    notifyListeners();
  }
}

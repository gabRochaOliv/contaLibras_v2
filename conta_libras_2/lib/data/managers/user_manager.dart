import 'package:flutter/foundation.dart';

class UserManager extends ChangeNotifier {
  static final UserManager _instance = UserManager._internal();

  factory UserManager() {
    return _instance;
  }

  UserManager._internal();

  String _userName = 'Estudante';
  String _userCategory = 'Estudante de Contábeis';

  String get userName => _userName;
  String get userCategory => _userCategory;

  void setUserData(String name, String category) {
    _userName = name;
    _userCategory = category.isNotEmpty ? category : 'Estudante de Contábeis';
    notifyListeners();
  }
}

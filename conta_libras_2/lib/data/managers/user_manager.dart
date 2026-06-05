import 'package:flutter/foundation.dart';

class UserManager extends ChangeNotifier {
  static final UserManager _instance = UserManager._internal();

  factory UserManager() {
    return _instance;
  }

  UserManager._internal();

  String _userName = 'Estudante';
  String _userCategory = 'Estudante de Contábeis';
  int _userAge = 0;

  String get userName => _userName;
  String get userCategory => _userCategory;
  int get userAge => _userAge;

  void setUserData(String name, String category, int age) {
    _userName = name;
    _userCategory = category.isNotEmpty ? category : 'Estudante de Contábeis';
    _userAge = age;
    notifyListeners();
  }
}

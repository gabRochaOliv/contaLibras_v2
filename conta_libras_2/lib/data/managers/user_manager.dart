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
  String _userEscolaridade = '';
  bool _userUsaLibras = false;
  String _userConhecimentoLibras = '';

  String get userName => _userName;
  String get userCategory => _userCategory;
  int get userAge => _userAge;
  String get userEscolaridade => _userEscolaridade;
  bool get userUsaLibras => _userUsaLibras;
  String get userConhecimentoLibras => _userConhecimentoLibras;

  void setUserData(
    String name,
    String category,
    int age, {
    String escolaridade = '',
    bool usaLibras = false,
    String conhecimentoLibras = '',
  }) {
    _userName = name;
    _userCategory = category.isNotEmpty ? category : 'Estudante de Contábeis';
    _userAge = age;
    _userEscolaridade = escolaridade;
    _userUsaLibras = usaLibras;
    _userConhecimentoLibras = conhecimentoLibras;
    notifyListeners();
  }
}

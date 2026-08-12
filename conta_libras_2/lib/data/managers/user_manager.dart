import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';

class UserManager extends ChangeNotifier {
  static final UserManager _instance = UserManager._internal();

  factory UserManager() {
    return _instance;
  }

  UserManager._internal();

  String _userId = '';
  String _userName = 'Estudante';
  String _userCategory = 'Estudante de Contábeis';
  int _userAge = 0;
  String _userEscolaridade = '';
  bool _userUsaLibras = false;
  String _userConhecimentoLibras = '';
  int? _cadastroId;

  String get userId => _userId;
  String get userName => _userName;
  String get userCategory => _userCategory;
  int get userAge => _userAge;
  String get userEscolaridade => _userEscolaridade;
  bool get userUsaLibras => _userUsaLibras;
  String get userConhecimentoLibras => _userConhecimentoLibras;
  int? get cadastroId => _cadastroId;

  void setUserData(
    String id,
    String name,
    String category,
    int age, {
    String escolaridade = '',
    bool usaLibras = false,
    String conhecimentoLibras = '',
    int? cadastroId,
  }) {
    _userId = id;
    _userName = name;
    _userCategory = category.isNotEmpty ? category : 'Estudante de Contábeis';
    _userAge = age;
    _userEscolaridade = escolaridade;
    _userUsaLibras = usaLibras;
    _userConhecimentoLibras = conhecimentoLibras;
    _cadastroId = cadastroId;
    notifyListeners();
  }

  void loadFromProfile(UserProfile profile) {
    setUserData(
      profile.id,
      profile.name,
      profile.category,
      profile.age,
      escolaridade: profile.escolaridade,
      usaLibras: profile.usaLibras,
      conhecimentoLibras: profile.conhecimentoLibras,
      cadastroId: profile.cadastroId,
    );
  }

  void setCadastroId(int id) {
    _cadastroId = id;
    notifyListeners();
  }

  UserProfile toProfile() => UserProfile(
        id: _userId,
        name: _userName,
        category: _userCategory,
        age: _userAge,
        escolaridade: _userEscolaridade,
        usaLibras: _userUsaLibras,
        conhecimentoLibras: _userConhecimentoLibras,
        cadastroId: _cadastroId,
      );

  void clear() {
    _userId = '';
    _userName = 'Estudante';
    _userCategory = 'Estudante de Contábeis';
    _userAge = 0;
    _userEscolaridade = '';
    _userUsaLibras = false;
    _userConhecimentoLibras = '';
    _cadastroId = null;
    notifyListeners();
  }
}

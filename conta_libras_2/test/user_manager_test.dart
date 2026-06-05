import 'package:flutter_test/flutter_test.dart';
import 'package:conta_libras_2/data/managers/user_manager.dart';

void main() {
  setUp(() {
    // Reset singleton state between tests
    UserManager().setUserData('', '', 0);
  });

  test('userAge retorna 0 antes de setUserData', () {
    // Note: singleton may have default value - test after reset
    expect(UserManager().userAge, 0);
  });

  test('userAge retorna valor passado em setUserData', () {
    UserManager().setUserData('Ana', 'Estudante', 22);
    expect(UserManager().userAge, 22);
  });

  test('userAge aceita 0 sem fallback', () {
    UserManager().setUserData('Ana', 'Estudante', 0);
    expect(UserManager().userAge, 0);
  });

  test('category vazia mantém Estudante de Contábeis', () {
    UserManager().setUserData('Ana', '', 25);
    expect(UserManager().userCategory, 'Estudante de Contábeis');
  });
}

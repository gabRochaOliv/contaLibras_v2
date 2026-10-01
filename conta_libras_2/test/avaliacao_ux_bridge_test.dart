import 'package:flutter_test/flutter_test.dart';
import 'package:conta_libras_2/data/managers/user_manager.dart';
import 'package:conta_libras_2/data/models/user_profile.dart';
import 'package:conta_libras_2/data/services/avaliacao_ux_bridge.dart';

void main() {
  late List<(Map<String, dynamic>, String)> enviados;
  late void Function(Map<String, dynamic>, String) enviarOriginal;

  setUp(() {
    enviados = [];
    enviarOriginal = AvaliacaoUxBridge.enviar;
    AvaliacaoUxBridge.enviar = (msg, origin) => enviados.add((msg, origin));
  });

  tearDown(() {
    AvaliacaoUxBridge.enviar = enviarOriginal;
    UserManager().clear();
  });

  test('mensagem segue a especificação do orientador', () {
    const perfil = UserProfile(
      id: '1',
      name: 'João Silva',
      category: 'Pessoa surda',
      age: 28,
      escolaridade: 'Ensino Superior',
      usaLibras: true,
      conhecimentoLibras: 'Avançado',
    );

    expect(AvaliacaoUxBridge.montarMensagem(perfil), {
      'tipo': 'PERFIL_CONTALIBRAS_COMPLETO',
      'payload': {
        'nome': 'João Silva',
        'idade': 28,
        'categoria': 'Pessoa surda',
        'escolaridade': 'Ensino Superior',
        'utilizaLibras': 'Sim',
        'conhecimentoLibras': 'Avançado',
      },
    });
  });

  test('campos vazios usam os mesmos padrões do coletor', () {
    const perfil = UserProfile(id: '2', name: '  ', category: '', age: 0);

    expect(AvaliacaoUxBridge.montarMensagem(perfil)['payload'], {
      'nome': 'Anônimo',
      'idade': '-',
      'categoria': 'Não informado',
      'escolaridade': 'Não informado',
      'utilizaLibras': 'Não',
      'conhecimentoLibras': 'Não informado',
    });
  });

  test('ativar um perfil envia só para conta-libras.labcct.net.br', () {
    UserManager().loadFromProfile(const UserProfile(
      id: '3',
      name: 'Ana',
      category: 'Estudante',
      age: 21,
    ));

    expect(enviados, hasLength(1));
    expect(enviados.single.$2, 'https://conta-libras.labcct.net.br');
    expect((enviados.single.$1['payload'] as Map)['nome'], 'Ana');
  });

  test('falha no envio não quebra a ativação do perfil', () {
    AvaliacaoUxBridge.enviar = (_, __) => throw StateError('sem janela pai');

    UserManager().loadFromProfile(const UserProfile(
      id: '4',
      name: 'Bia',
      category: 'Professor',
      age: 40,
    ));

    expect(UserManager().userName, 'Bia');
  });
}

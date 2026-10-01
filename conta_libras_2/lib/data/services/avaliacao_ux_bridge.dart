import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import 'parent_window_stub.dart'
    if (dart.library.html) 'parent_window_web.dart' as parent_window;

/// Envia o perfil do avaliador para o ambiente de avaliação de UX do
/// orientador (conta-libras.labcct.net.br), que exibe o app num iframe e grava
/// áudio/transcrição enquanto a pessoa usa a aplicação.
///
/// A página dele escuta `window.postMessage` com o tipo
/// [tipoMensagem] e preenche o relatório com o `payload`. O envio é restrito a
/// [targetOrigin]: em qualquer outro site (ou fora de um iframe) o navegador
/// descarta a mensagem, e fora da web (Android/iOS) nada é enviado.
class AvaliacaoUxBridge {
  AvaliacaoUxBridge._();

  static const String targetOrigin = 'https://conta-libras.labcct.net.br';
  static const String tipoMensagem = 'PERFIL_CONTALIBRAS_COMPLETO';

  /// Função que efetivamente envia a mensagem; trocada nos testes.
  @visibleForTesting
  static void Function(Map<String, dynamic> mensagem, String targetOrigin)
      enviar = parent_window.postMessageToParent;

  /// Monta a mensagem no formato esperado pelo coletor de UX — mesmos nomes
  /// de campo e mesmos valores padrão da especificação do orientador.
  static Map<String, dynamic> montarMensagem(UserProfile perfil) {
    String ouPadrao(String valor) =>
        valor.trim().isEmpty ? 'Não informado' : valor.trim();

    return {
      'tipo': tipoMensagem,
      'payload': {
        'nome': perfil.name.trim().isEmpty ? 'Anônimo' : perfil.name.trim(),
        'idade': perfil.age > 0 ? perfil.age : '-',
        'categoria': ouPadrao(perfil.category),
        'escolaridade': ouPadrao(perfil.escolaridade),
        'utilizaLibras': perfil.usaLibras ? 'Sim' : 'Não',
        'conhecimentoLibras': ouPadrao(perfil.conhecimentoLibras),
      },
    };
  }

  /// Notifica o ambiente de avaliação sobre o perfil ativo. Nunca lança:
  /// uma falha aqui não pode atrapalhar o uso do app.
  static void notificarPerfil(UserProfile perfil) {
    try {
      enviar(montarMensagem(perfil), targetOrigin);
    } catch (e) {
      debugPrint('AvaliacaoUxBridge: falha ao enviar perfil: $e');
    }
  }
}

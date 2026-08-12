import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import '../../core/constants.dart';

/// Envia o cadastro (first access) pro backend assim que ele é concluído,
/// pra sabermos no dashboard quem se cadastrou mesmo sem responder o
/// questionário depois. É melhor esforço: falha de rede não deve travar
/// nem interromper o fluxo do usuário.
class CadastroService {
  Future<int?> register(UserProfile profile, {http.Client? httpClient}) async {
    final client = httpClient ?? http.Client();
    try {
      final payload = {
        'nome': profile.name,
        'idade': profile.age,
        'categoria': profile.category,
        'escolaridade': profile.escolaridade,
        'usa_libras': profile.usaLibras,
        'conhecimento_libras': profile.conhecimentoLibras,
      };

      final response = await client.post(
        Uri.parse('${AppConstants.apiBaseUrl}/cadastro'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(payload),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['id'] as int?;
    } catch (e) {
      debugPrint('[CadastroService] falha ao registrar cadastro: $e');
      return null;
    }
  }
}

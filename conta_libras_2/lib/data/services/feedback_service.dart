import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../managers/user_manager.dart';
import '../../core/constants.dart';

class FeedbackService extends ChangeNotifier {
  static final FeedbackService _instance = FeedbackService._internal();

  factory FeedbackService() {
    return _instance;
  } 

  FeedbackService._internal();

  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;

  Future<void> submit(
    Map<int, int> answers, {
    Map<String, String> openAnswers = const {},
    http.Client? httpClient,
  }) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    final client = httpClient ?? http.Client();
    try {
      final payload = {
        'nome': UserManager().userName,
        'idade': UserManager().userAge,
        'categoria': UserManager().userCategory,
        'escolaridade': UserManager().userEscolaridade,
        'usa_libras': UserManager().userUsaLibras,
        'conhecimento_libras': UserManager().userConhecimentoLibras,
        'comentario_gostou': openAnswers['gostou'] ?? '',
        'comentario_melhorar': openAnswers['melhorar'] ?? '',
        'comentario_sugestao': openAnswers['sugestao'] ?? '',
        'respostas': answers.entries
            .map((e) => {'pergunta_id': e.key, 'valor': e.value})
            .toList(),
        'timestamp': DateTime.now().toIso8601String(),
        'cadastro_id': UserManager().cadastroId,
      };

      final response = await client.post(
        Uri.parse('${AppConstants.apiBaseUrl}/feedback'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(payload),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Erro ao enviar avaliação. Verifique sua conexão.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

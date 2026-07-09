import 'dart:convert';
import 'package:http/http.dart' as http;

class OneSignalService {
  static final OneSignalService _instance = OneSignalService._internal();

  factory OneSignalService() {
    return _instance;
  }

  OneSignalService._internal();

  late String _appId;
  late String _restApiKey;

  /// Inicializa o serviço do OneSignal
  /// Variáveis de ambiente: ONESIGNAL_APP_ID e ONESIGNAL_REST_API_KEY
  void initialize({required String appId, required String restApiKey}) {
    _appId = appId;
    _restApiKey = restApiKey;
  }

  /// Envia uma notificação push
  /// [title]: Título da notificação
  /// [message]: Corpo da notificação
  /// [segment]: "all" para todos os usuários, "premium" para clientes premium
  /// [data]: Dados adicionais para a notificação (opcional)
  Future<Map<String, dynamic>> sendNotification({
    required String title,
    required String message,
    String segment = 'all',
    Map<String, String>? data,
  }) async {
    try {
      // Valida os parâmetros
      if (title.isEmpty) {
        throw Exception('Título da notificação não pode ser vazio');
      }
      if (message.isEmpty) {
        throw Exception('Mensagem da notificação não pode ser vazia');
      }
      if (_appId.isEmpty || _restApiKey.isEmpty) {
        throw Exception('OneSignal não foi inicializado corretamente');
      }

      // Mapeia o segmento para o formato do OneSignal
      final segments = _getSegments(segment);

      // Constrói o corpo da requisição
      final body = {
        'app_id': _appId,
        'contents': {'en': message},
        'headings': {'en': title},
      };

      // Adiciona segmentação
      if (segments.isNotEmpty) {
        body['included_segments'] = segments;
      }

      // Adiciona dados adicionais se fornecidos
      if (data != null && data.isNotEmpty) {
        body['data'] = data;
      }

      // Faz a requisição POST
      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Basic $_restApiKey',
        },
        body: jsonEncode(body),
      );

      // Verifica o status da resposta
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'success': true,
          'message': 'Notificação enviada com sucesso',
          'notificationId': result['body']?['notification_id'],
        };
      } else {
        throw Exception(
          'Erro ao enviar notificação: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Erro ao enviar notificação: $e');
    }
  }

  /// Envia uma notificação para usuários específicos
  /// [title]: Título da notificação
  /// [message]: Corpo da notificação
  /// [userIds]: Lista de IDs de usuários OneSignal
  /// [data]: Dados adicionais para a notificação (opcional)
  Future<Map<String, dynamic>> sendNotificationToUsers({
    required String title,
    required String message,
    required List<String> userIds,
    Map<String, String>? data,
  }) async {
    try {
      if (title.isEmpty) {
        throw Exception('Título da notificação não pode ser vazio');
      }
      if (message.isEmpty) {
        throw Exception('Mensagem da notificação não pode ser vazia');
      }
      if (userIds.isEmpty) {
        throw Exception('Lista de usuários não pode ser vazia');
      }
      if (_appId.isEmpty || _restApiKey.isEmpty) {
        throw Exception('OneSignal não foi inicializado corretamente');
      }

      final body = {
        'app_id': _appId,
        'contents': {'en': message},
        'headings': {'en': title},
        'include_external_user_ids': userIds,
      };

      if (data != null && data.isNotEmpty) {
        body['data'] = data;
      }

      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Basic $_restApiKey',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'success': true,
          'message':
              'Notificação enviada com sucesso para ${userIds.length} usuário(s)',
          'notificationId': result['body']?['notification_id'],
        };
      } else {
        throw Exception(
          'Erro ao enviar notificação: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Erro ao enviar notificação: $e');
    }
  }

  /// Mapeia o segmento em português para o formato do OneSignal
  List<String> _getSegments(String segment) {
    switch (segment.toLowerCase()) {
      case 'todos':
      case 'all':
        return ['All'];
      case 'premium':
      case 'premium_users':
        return ['Premium'];
      default:
        return ['All'];
    }
  }
}

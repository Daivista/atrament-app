import 'package:dio/dio.dart';

/// Wyjątek z komunikatem gotowym do pokazania użytkownikowi.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiClient {
  final Dio _dio;

  ApiClient([Dio? dio])
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
            ),
          );

  /// Pobiera listę ID modeli z GET {baseUrl}/v1/models.
  /// baseUrl np. "http://10.0.2.2:1234" (z /v1 lub bez — normalizujemy).
  Future<List<String>> fetchModels(String baseUrl, {String? apiKey}) async {
    final url = '${_normalizeBase(baseUrl)}/v1/models';
    try {
      final resp = await _dio.get(
        url,
        options: Options(
          headers: {
            if (apiKey != null && apiKey.isNotEmpty)
              'Authorization': 'Bearer $apiKey',
          },
        ),
      );
      final data = resp.data;
      if (data is! Map || data['data'] is! List) {
        throw ApiException('Nieoczekiwany format odpowiedzi z $url.');
      }
      final models = (data['data'] as List)
          .map((m) => (m is Map && m['id'] != null) ? m['id'].toString() : null)
          .whereType<String>()
          .toList();
      if (models.isEmpty) {
        throw ApiException(
          'Serwer odpowiedział, ale lista modeli jest pusta. '
          'Czy w LM Studio/Ollama załadowano model?',
        );
      }
      return models;
    } on DioException catch (e) {
      throw ApiException(_mapDioError(e));
    }
  }

  String _normalizeBase(String baseUrl) {
    var b = baseUrl.trim();
    while (b.endsWith('/')) {
      b = b.substring(0, b.length - 1);
    }
    if (b.endsWith('/v1')) b = b.substring(0, b.length - 3);
    return b;
  }

  String _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Przekroczono czas połączenia. Sprawdź czy serwer działa.';
      case DioExceptionType.connectionError:
        return 'Nie można połączyć się z serwerem. '
            'Sprawdź adres, port i czy serwer jest uruchomiony.';
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        if (code == 401 || code == 403) {
          return 'Błąd autoryzacji ($code). Sprawdź klucz API.';
        }
        return 'Serwer zwrócił błąd $code.';
      default:
        return 'Błąd połączenia: ${e.message ?? e.type.name}';
    }
  }
}

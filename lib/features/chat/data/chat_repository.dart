import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/network/sse_parser.dart';
import 'chat_models.dart';

class ChatRepository {
  final Dio _dio;
  ChatRepository([Dio? dio])
    : _dio =
          dio ?? Dio(BaseOptions(connectTimeout: const Duration(seconds: 10)));

  Stream<ChatChunk> streamCompletion({
    required String baseUrl,
    String? apiKey,
    required String model,
    required List<ChatMessage> messages,
    CancelToken? cancelToken,
  }) async* {
    final url = '${_normalizeBase(baseUrl)}/v1/chat/completions';

    try {
      final response = await _dio.post(
        url,
        data: {
          'model': model,
          'messages': messages.map((m) => m.toJson()).toList(),
          'stream': true,
        },
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: Duration.zero,
          headers: {
            if (apiKey != null && apiKey.isNotEmpty)
              'Authorization': 'Bearer $apiKey',
          },
        ),
        cancelToken: cancelToken,
      );

      final parser = SseParser();
      final body = response.data as ResponseBody;
      final stream = body.stream.cast<List<int>>().transform(utf8.decoder);

      await for (final text in stream) {
        for (final event in parser.addChunk(text)) {
          if (event.isDone) {
            yield const ChatChunk(done: true);
            return;
          }
          final map = _tryDecode(event.data);
          if (map == null) continue;
          final choices = map['choices'];
          if (choices is! List || choices.isEmpty) continue;
          final delta = choices[0]['delta'];
          if (delta is! Map) continue;
          final content = delta['content'] as String?;
          final reasoning =
              (delta['reasoning_content'] ?? delta['reasoning']) as String?;
          if (content != null || reasoning != null) {
            yield ChatChunk(contentDelta: content, reasoningDelta: reasoning);
          }
        }
      }
    } on DioException catch (e) {
      // Anulowanie (Stop / wyjście z ekranu) — kończymy stream cicho, to nie błąd.
      if (e.type == DioExceptionType.cancel) return;
      // Inne błędy: odczytujemy body (np. 400 "model not loaded") dla czytelności.
      String detail = e.message ?? e.type.name;
      try {
        final data = e.response?.data;
        if (data is ResponseBody) {
          final bytes = <int>[];
          await for (final c in data.stream) {
            bytes.addAll(c);
          }
          detail = utf8.decode(bytes, allowMalformed: true);
        } else if (data != null) {
          detail = data.toString();
        }
      } catch (_) {}
      throw Exception(
        'Serwer odrzucił żądanie (${e.response?.statusCode}): $detail',
      );
    }
  }

  Map<String, dynamic>? _tryDecode(String s) {
    try {
      final d = jsonDecode(s);
      return d is Map<String, dynamic> ? d : null;
    } catch (_) {
      return null;
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
}

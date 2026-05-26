/// Parser transportu Server-Sent Events (manifest sekcja 4).
/// Zajmuje się WYŁĄCZNIE warstwą SSE: buforuje chunki przez granice TCP,
/// wydziela kompletne linie, zwraca surowe payloady `data:`.
/// NIE rozumie semantyki JSON (choices/delta) — to robi ChatRepository.
class SseEvent {
  final String data; // payload po "data:" (np. '{"choices":[...]}')
  final bool isDone; // true gdy "[DONE]" (terminator OpenAI/LM Studio)
  const SseEvent(this.data, {this.isDone = false});
}

class SseParser {
  // Niekompletna linia z poprzedniego chunka (TCP może rozciąć w środku).
  String _pending = '';

  /// Przyjmuje fragment tekstu (chunk z dio), zwraca kompletne zdarzenia.
  /// Niekompletna końcówka zostaje w buforze do następnego chunka.
  List<SseEvent> addChunk(String chunk) {
    _pending += chunk;
    final events = <SseEvent>[];

    final lines = _pending.split('\n');
    // Ostatni fragment może być niekompletny (brak \n na końcu) → bufor.
    _pending = lines.removeLast();

    for (final raw in lines) {
      // Normalizacja CRLF (niektóre serwery wysyłają \r\n).
      final line = raw.endsWith('\r') ? raw.substring(0, raw.length - 1) : raw;

      if (line.isEmpty) continue; // pusta linia = separator zdarzeń
      if (line.startsWith(':')) continue; // komentarz = keepalive, ignoruj

      if (line.startsWith('data:')) {
        // "data:" + opcjonalna spacja + payload
        final payload = line.substring(5).trimLeft();
        if (payload == '[DONE]') {
          events.add(const SseEvent('', isDone: true));
        } else if (payload.isNotEmpty) {
          events.add(SseEvent(payload));
        }
      }
      // Pola event:/id:/retry: ignorujemy w tej wersji (OpenAI/LM Studio flow).
      // Anthropic (event: <typ>) dostanie osobny mapper przy backendzie Anthropic.
    }
    return events;
  }

  /// Reset bufora (np. przy ponownym użyciu parsera dla nowego streamu).
  void reset() => _pending = '';
}

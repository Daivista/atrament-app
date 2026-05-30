import 'package:flutter/foundation.dart';

/// Poziom logowania. Konwencja:
/// - debug: szczegółowy flow (rzadko, F2 verbose mode)
/// - info: pomyślne akcje, zmiany stanu, eventy user-level
/// - warn: degradacja niefatalna (timeout retry, slow response)
/// - error: nieudana operacja (handled error: chwytany przez try/catch)
///   Plus tag='crash' wyznacza UNHANDLED exception złapaną przez global
///   error handler w main.dart (FlutterError.onError lub PlatformDispatcher).
enum LogLevel { debug, info, warn, error }

/// Pojedynczy wpis w log bufferze.
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String tag;
  final String message;

  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.tag,
    required this.message,
  });

  /// Format do exportu i do print w debug mode:
  /// `[2026-05-30T14:32:18.123] [INFO ] [chat] Send: chatId=abc, model=gemma`
  String get formatted {
    final t = timestamp.toIso8601String();
    final lvl = level.name.toUpperCase().padRight(5);
    return '[$t] [$lvl] [$tag] $message';
  }

  /// Format do UI (krótszy, bez ISO timestampu — tylko godzina).
  String get formattedShort {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    final s = timestamp.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  /// Czy ten entry jest crashem (unhandled exception złapanym przez global
  /// error handler). Sprawdzane przez tag, nie level — bo wiele errorów to
  /// handled (np. send error w try/catch), tylko crashy mają tag='crash'.
  bool get isCrash => tag == 'crash';
}

/// Singleton in-memory ring buffer dla eventów aplikacji.
///
/// **Privacy:** NIE loggujemy treści wiadomości ani API keys. Loggujemy tylko
/// eventy (akcje user, parametry numeric, długość, błędy bez payload).
/// Pełne HTTP request/response body to feature F2 (verbose mode opt-in
/// z privacy warningiem).
///
/// **Wyjątek od reguły „no content":** `buildResponseReportText()` zawiera
/// treść wiadomości — ale TYLKO jako wynik świadomej akcji usera (Raportuj
/// odpowiedź w bańce → dialog z disclaimerem → share intent z wyborem
/// adresata). Per-message opt-in, nie globalna telemetria.
///
/// **Dwa bufory:**
/// - `_entries` — wszystkie eventy (max 500, ring buffer, najstarsze wypadają)
/// - `_crashes` — osobna lista crashy (max 50, ring buffer wewnątrz crashy)
///
/// ChangeNotifier żeby UI auto-rebuildował się gdy nowy log entry wpadnie.
/// Singleton bo logger musi być dostępny z dowolnego miejsca w kodzie bez
/// `ref` (zwłaszcza z global error handlers w main.dart — tam Riverpod
/// jeszcze nie istnieje).
class LogBuffer extends ChangeNotifier {
  static final LogBuffer _instance = LogBuffer._();
  factory LogBuffer() => _instance;
  LogBuffer._() {
    _entries.add(LogEntry(
      timestamp: DateTime.now(),
      level: LogLevel.info,
      tag: 'app',
      message: 'Log buffer initialized',
    ));
  }

  static const int maxEntries = 500;
  static const int maxCrashes = 50;

  final List<LogEntry> _entries = [];
  final List<LogEntry> _crashes = [];

  List<LogEntry> get entries => List.unmodifiable(_entries);
  List<LogEntry> get crashes => List.unmodifiable(_crashes);
  int get length => _entries.length;
  int get crashCount => _crashes.length;
  bool get hasCrashes => _crashes.isNotEmpty;

  void debug(String tag, String message) => _add(LogLevel.debug, tag, message);
  void info(String tag, String message) => _add(LogLevel.info, tag, message);
  void warn(String tag, String message) => _add(LogLevel.warn, tag, message);
  void error(String tag, String message) => _add(LogLevel.error, tag, message);

  /// Unhandled exception z global error handlera (main.dart).
  void crash(String message) {
    _add(LogLevel.error, 'crash', message);
  }

  void _add(LogLevel level, String tag, String message) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      tag: tag,
      message: _redact(message),
    );
    _entries.add(entry);
    if (_entries.length > maxEntries) {
      _entries.removeRange(0, _entries.length - maxEntries);
    }
    if (entry.isCrash) {
      _crashes.add(entry);
      if (_crashes.length > maxCrashes) {
        _crashes.removeRange(0, _crashes.length - maxCrashes);
      }
    }
    if (kDebugMode) {
      // ignore: avoid_print
      debugPrint(entry.formatted);
    }
    notifyListeners();
  }

  /// Auto-redaction wrażliwych wzorców ZANIM trafią do bufora oraz
  /// ZANIM trafią do raportów (buildExportText/buildCrashReportText/
  /// buildResponseReportText). Defensywnie — nawet jeśli wywołujący
  /// zapomni, nie wyciekną do exportu.
  static String _redact(String msg) {
    var redacted = msg;
    redacted = redacted.replaceAllMapped(
      RegExp(r'(Bearer\s+)[A-Za-z0-9\-_.~+/]+=*'),
      (m) => '${m.group(1)}***',
    );
    redacted = redacted.replaceAllMapped(
      RegExp(r'(https?://[^:\s]+:)[^@\s]+(@)'),
      (m) => '${m.group(1)}***${m.group(2)}',
    );
    redacted = redacted.replaceAllMapped(
      RegExp(
        r'''(["']?(?:api_key|apiKey)["']?\s*[:=]\s*["']?)[^"',\s}]+'''),
      (m) => '${m.group(1)}***',
    );
    return redacted;
  }

  void clear() {
    _entries.clear();
    notifyListeners();
  }

  void clearCrashes() {
    _crashes.clear();
    notifyListeners();
  }

  void clearAll() {
    _entries.clear();
    _crashes.clear();
    notifyListeners();
  }

  String buildExportText({
    required String appName,
    required String appVersion,
    required String buildMode,
    required Map<String, String> stats,
  }) {
    final buf = StringBuffer();
    buf.writeln('=== Atrament — Diagnostics ===');
    buf.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buf.writeln();
    buf.writeln('--- O aplikacji ---');
    buf.writeln('App: $appName $appVersion');
    buf.writeln('Build mode: $buildMode');
    buf.writeln();
    buf.writeln('--- Statystyki ---');
    stats.forEach((k, v) => buf.writeln('$k: $v'));
    if (_crashes.isNotEmpty) {
      buf.writeln();
      buf.writeln('--- Awarie (${_crashes.length}) ---');
      for (final c in _crashes) {
        buf.writeln(c.formatted);
        buf.writeln();
      }
    }
    buf.writeln();
    buf.writeln('--- Logi (${_entries.length} entries) ---');
    for (final e in _entries) {
      buf.writeln(e.formatted);
    }
    return buf.toString();
  }

  String buildCrashReportText({
    required String appName,
    required String appVersion,
    required String buildMode,
    required Map<String, String> stats,
  }) {
    final buf = StringBuffer();
    buf.writeln('=== Atrament — Crash Report ===');
    buf.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buf.writeln();
    buf.writeln('--- O aplikacji ---');
    buf.writeln('App: $appName $appVersion');
    buf.writeln('Build mode: $buildMode');
    buf.writeln();
    buf.writeln('--- Statystyki ---');
    stats.forEach((k, v) => buf.writeln('$k: $v'));
    buf.writeln();
    if (_crashes.isEmpty) {
      buf.writeln('--- Brak awarii ---');
      return buf.toString();
    }
    buf.writeln('--- Awarie (${_crashes.length}) ---');
    for (final c in _crashes) {
      buf.writeln(c.formatted);
      buf.writeln();
    }
    final contextEntries = _entries.length <= 50
        ? _entries
        : _entries.sublist(_entries.length - 50);
    buf.writeln('--- Kontekst (ostatnie ${contextEntries.length} entries) ---');
    for (final e in contextEntries) {
      buf.writeln(e.formatted);
    }
    return buf.toString();
  }

  /// Buduje raport problematycznej odpowiedzi modelu dla share intent.
  /// **Świadomy opt-in user'a** — zawiera treść wiadomości (jedyny raport
  /// który ją zawiera). User otwiera przez Raportuj odpowiedź → dialog →
  /// share intent → wybiera komu udostępnić.
  ///
  /// Auto-redaction nadal działa — message strings (userQuestion,
  /// assistantResponse, systemPrompt) przepuszczane przez _redact zanim
  /// trafią do tekstu raportu, więc Bearer/credentials/api_key wzorce
  /// zostaną zredagowane nawet jeśli przez przypadek znalazły się w
  /// treści wiadomości.
  String buildResponseReportText({
    required String appName,
    required String appVersion,
    required String buildMode,
    required String model,
    required Map<String, String> parameters,
    required String? systemPrompt,
    required String? userQuestion,
    required String assistantResponse,
    required String category,
    required String? userComment,
  }) {
    final buf = StringBuffer();
    buf.writeln('=== Atrament — Response Report ===');
    buf.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buf.writeln();
    buf.writeln('--- O aplikacji ---');
    buf.writeln('App: $appName $appVersion');
    buf.writeln('Build mode: $buildMode');
    buf.writeln();
    buf.writeln('--- Parametry rozmowy ---');
    buf.writeln('Model: $model');
    parameters.forEach((k, v) => buf.writeln('$k: $v'));
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      buf.writeln();
      buf.writeln('--- System prompt ---');
      buf.writeln(_redact(systemPrompt));
    }
    buf.writeln();
    buf.writeln('--- Kategoria ---');
    buf.writeln(category);
    if (userComment != null && userComment.trim().isNotEmpty) {
      buf.writeln();
      buf.writeln('--- Komentarz użytkownika ---');
      buf.writeln(_redact(userComment.trim()));
    }
    if (userQuestion != null && userQuestion.isNotEmpty) {
      buf.writeln();
      buf.writeln('--- Pytanie użytkownika ---');
      buf.writeln(_redact(userQuestion));
    }
    buf.writeln();
    buf.writeln('--- Raportowana odpowiedź modelu ---');
    buf.writeln(_redact(assistantResponse));
    final contextEntries = _entries.length <= 20
        ? _entries
        : _entries.sublist(_entries.length - 20);
    buf.writeln();
    buf.writeln(
        '--- Kontekst techniczny (ostatnie ${contextEntries.length} entries) ---');
    for (final e in contextEntries) {
      buf.writeln(e.formatted);
    }
    return buf.toString();
  }
}

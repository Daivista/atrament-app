import 'package:flutter/foundation.dart';

/// Poziom logowania. Konwencja:
/// - debug: szczegółowy flow (rzadko, F2 verbose mode)
/// - info: pomyślne akcje, zmiany stanu, eventy user-level
/// - warn: degradacja niefatalna (timeout retry, slow response)
/// - error: nieudana operacja
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
}

/// Singleton in-memory ring buffer dla eventów aplikacji.
///
/// **Privacy:** NIE loggujemy treści wiadomości ani API keys. Loggujemy tylko
/// eventy (akcje user, parametry numeric, długość, błędy bez payload).
/// Pełne HTTP request/response body to feature F2 (verbose mode opt-in
/// z privacy warningiem).
///
/// ChangeNotifier żeby UI (DiagnosticsScreen) auto-rebuildował się gdy nowy
/// log entry wpadnie. Singleton bo logger musi być dostępny z dowolnego
/// miejsca w kodzie bez `ref`.
class LogBuffer extends ChangeNotifier {
  static final LogBuffer _instance = LogBuffer._();
  factory LogBuffer() => _instance;
  LogBuffer._() {
    // Pierwszy entry przy starcie bufora — przydatne do określenia uptime sesji.
    _entries.add(LogEntry(
      timestamp: DateTime.now(),
      level: LogLevel.info,
      tag: 'app',
      message: 'Log buffer initialized',
    ));
  }

  /// Maksymalna liczba entries — ring buffer. Po przekroczeniu najstarsze
  /// są usuwane. 500 wystarcza na sesyjny debug F1; pełny audit log to F2
  /// z file-based persistence.
  static const int maxEntries = 500;
  final List<LogEntry> _entries = [];

  List<LogEntry> get entries => List.unmodifiable(_entries);
  int get length => _entries.length;

  void debug(String tag, String message) => _add(LogLevel.debug, tag, message);
  void info(String tag, String message) => _add(LogLevel.info, tag, message);
  void warn(String tag, String message) => _add(LogLevel.warn, tag, message);
  void error(String tag, String message) => _add(LogLevel.error, tag, message);

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
    if (kDebugMode) {
      // Print w debug mode dla łatwości developmentu. W release print nic
      // nie robi, więc nie ma overheadu. Logger expensive operations są
      // ograniczone do entries+redaction (mała praca).
      // ignore: avoid_print
      debugPrint(entry.formatted);
    }
    notifyListeners();
  }

  /// Auto-redaction wrażliwych wzorców ZANIM trafią do bufora. Defensywnie —
  /// nawet jeśli wywołujący zapomni, nie wyciekną do exportu.
  ///
  /// Wzorce:
  /// - `Bearer XXX` (Authorization header) → `Bearer ***`
  /// - `https://user:pass@host` (embedded credentials) → `https://user:***@host`
  /// - `apiKey: XXX` lub `"api_key":"XXX"` (luźny patten z JSON-like) → `***`
  static String _redact(String msg) {
    var redacted = msg;
    // Bearer tokens
    redacted = redacted.replaceAllMapped(
      RegExp(r'(Bearer\s+)[A-Za-z0-9\-_.~+/]+=*'),
      (m) => '${m.group(1)}***',
    );
    // URL z user:pass@
    redacted = redacted.replaceAllMapped(
      RegExp(r'(https?://[^:\s]+:)[^@\s]+(@)'),
      (m) => '${m.group(1)}***${m.group(2)}',
    );
    // api_key/apiKey value w JSON-like patternie
    redacted = redacted.replaceAllMapped(
      RegExp(
        r'''(["']?(?:api_key|apiKey)["']?\s*[:=]\s*["']?)[^"',\s}]+'''),
      (m) => '${m.group(1)}***',
    );
    return redacted;
  }

  /// Wyczyść bufor. Używane przez UI ("Wyczyść logi") i w testach.
  void clear() {
    _entries.clear();
    notifyListeners();
  }

  /// Zbuduj pełny tekst diagnostics + logi do share intent.
  /// Format human-readable, łatwy do wklejenia w email/messenger/issue tracker.
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
    buf.writeln();
    buf.writeln('--- Logi (${_entries.length} entries) ---');
    for (final e in _entries) {
      buf.writeln(e.formatted);
    }
    return buf.toString();
  }
}

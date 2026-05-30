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
/// **Dwa bufory:**
/// - `_entries` — wszystkie eventy (max 500, ring buffer, najstarsze wypadają)
/// - `_crashes` — osobna lista crashy (max 50, ring buffer wewnątrz crashy)
///
/// Crashy trzymane osobno żeby crash sprzed kilkuset wiadomości nie wypadł
/// z głównego bufora przy aktywnym użyciu — user musi mieć szansę zobaczyć
/// go nawet jeśli otwiera diagnostykę długo po incydencie.
///
/// ChangeNotifier żeby UI (DiagnosticsScreen) auto-rebuildował się gdy nowy
/// log entry wpadnie. Singleton bo logger musi być dostępny z dowolnego
/// miejsca w kodzie bez `ref` (zwłaszcza z global error handlers w main.dart
/// — tam Riverpod jeszcze nie istnieje).
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

  /// Maksymalna liczba entries w głównym buforze — ring buffer.
  static const int maxEntries = 500;

  /// Maksymalna liczba crashy w osobnym buforze — odporna na rotation
  /// głównego bufora. 50 wystarcza na realnie spotykane scenariusze
  /// (rzadko więcej niż kilka crashy w sesji).
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
  /// Zapisuje do _entries (jak normal log) ORAZ do osobnego _crashes
  /// (z niezależną rotation, żeby crash sprzed dawnych sesji nie wypadł).
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
    // Crashes — osobny bufor z niezależną rotation.
    if (entry.isCrash) {
      _crashes.add(entry);
      if (_crashes.length > maxCrashes) {
        _crashes.removeRange(0, _crashes.length - maxCrashes);
      }
    }
    if (kDebugMode) {
      // Print w debug mode dla łatwości developmentu. W release print nic
      // nie robi, więc nie ma overheadu.
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
  /// - `apiKey: XXX` lub `"api_key":"XXX"` (luźny pattern z JSON-like) → `***`
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

  /// Wyczyść główny bufor entries. NIE czyści crashes (osobny bufor,
  /// świadomie — user może chcieć zachować crash report nawet po wyczyszczeniu
  /// normalnych logów).
  void clear() {
    _entries.clear();
    notifyListeners();
  }

  /// Wyczyść bufor crashy.
  void clearCrashes() {
    _crashes.clear();
    notifyListeners();
  }

  /// Wyczyść oba bufory naraz — używane przez UI gdy user wybiera
  /// "wyczyść wszystko" w diagnostyce.
  void clearAll() {
    _entries.clear();
    _crashes.clear();
    notifyListeners();
  }

  /// Zbuduj pełny tekst diagnostics + WSZYSTKIE logi do share intent.
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

  /// Zbuduj tekst CRASH REPORT do share intent — tylko crashy + ostatnie
  /// 50 entries kontekstu przed pierwszym crashem (żeby zobaczyć co user
  /// robił prowadząc do crashu).
  ///
  /// Używane przez button "Wyślij raport o awarii" w diagnostyce. Mniejszy
  /// payload niż buildExportText, skoncentrowany tylko na crashes.
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
    // Ostatnie 50 entries jako kontekst — co user robił przed crashem.
    final contextEntries = _entries.length <= 50
        ? _entries
        : _entries.sublist(_entries.length - 50);
    buf.writeln('--- Kontekst (ostatnie ${contextEntries.length} entries) ---');
    for (final e in contextEntries) {
      buf.writeln(e.formatted);
    }
    return buf.toString();
  }
}

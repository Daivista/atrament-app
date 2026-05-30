import 'package:flutter_riverpod/legacy.dart'; // ChangeNotifierProvider — Riverpod 3.x przeniósł do legacy
import 'log_buffer.dart';

/// Provider dla LogBuffera (singleton). Używaj `ref.watch(logBufferProvider)`
/// w UI żeby auto-rebuild gdy nowy log entry przychodzi.
///
/// Spoza UI (np. w ChatController) używaj bezpośrednio `LogBuffer()` —
/// singleton, nie potrzeba ref. Provider jest tylko dla reaktywności UI.
///
/// Tracked TODO (F2): migracja na `NotifierProvider<LogNotifier, List<LogEntry>>`
/// zanim Riverpod 4.x usunie legacy package. ChangeNotifierProvider jest
/// supported ale legacy w Riverpod 3.x — działa, ale nie jest idiomatyczne.
final logBufferProvider = ChangeNotifierProvider<LogBuffer>(
  (ref) => LogBuffer(),
);

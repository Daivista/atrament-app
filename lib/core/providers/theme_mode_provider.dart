import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Klucz w SharedPreferences. Wartości: 'system' | 'light' | 'dark'.
/// String zamiast int dla czytelności gdyby ktoś debugował zawartość prefs.
const _kThemeModeKey = 'theme_mode';

/// Notifier zarządzający wyborem motywu z persystencją w SharedPreferences.
/// Default na start (gdy klucz nie istnieje): ThemeMode.system — szanuje
/// systemowe ustawienie Androida bez wymuszania wyboru.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Start z system, asynchronicznie ładujemy zapisaną wartość.
    // MaterialApp najpierw zobaczy system, potem rebuild gdy load się dokończy.
    _loadFromPrefs();
    return ThemeMode.system;
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_kThemeModeKey);
      final mode = _parse(stored);
      if (mode != state) state = mode;
    } catch (_) {
      // Defensywnie: błąd I/O prefs nie powinien crashować appki.
    }
  }

  /// Ustaw nowy motyw + zapisz do prefs.
  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kThemeModeKey, _serialize(mode));
    } catch (_) {
      // Stan w pamięci się zmienił nawet jeśli zapis zawiódł — user widzi
      // efekt; przy następnym uruchomieniu zobaczy stary wybór z prefs.
    }
  }

  /// Cyklicznie: system → light → dark → system. Używane przez 3-state toggle
  /// w AppBar listy rozmów.
  Future<void> cycle() {
    final next = switch (state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    return setMode(next);
  }

  static ThemeMode _parse(String? s) {
    switch (s) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  static String _serialize(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

import 'package:flutter/material.dart';

/// Tokeny spacing — wierne mapowanie z istniejących użyć w projekcie.
/// Nie zmieniaj wartości bez świadomej decyzji wizualnej (4-pt grid byłby
/// alternatywą; obecnie utrzymujemy 1:1 z kodem dnia 0).
class Spacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}

/// Semantyczne kolory recovery/warning (resume flow banner, utracony klucz API).
/// Cztery sloty, nawet jeśli w Kroku 1 nie wszystkie są jeszcze używane —
/// definicja kompletna teraz jest tańsza niż dokładanie pól później.
///
/// Krok 1 — paleta IDENTYCZNA light/dark, mapuje obecne Colors.orange.shade*
/// (zachowanie 1:1, zero zmian wizualnych). Krok 2 — empirycznie poprawny
/// ciemny wariant przy refactorze chat_screen, gdy widać banner na żywym tle.
class AppColors extends ThemeExtension<AppColors> {
  final Color warning;
  final Color warningContainer;
  final Color onWarning;
  final Color onWarningContainer;

  const AppColors({
    required this.warning,
    required this.warningContainer,
    required this.onWarning,
    required this.onWarningContainer,
  });

  // Domyślny zestaw — wierne odwzorowanie obecnych Colors.orange.shade*.
  // shade800 ≈ #EF6C00 (warning), shade50 ≈ #FFF3E0 (container),
  // shade900 ≈ #E65100 (onContainer), biel na shade800 dla onWarning.
  static const _defaults = AppColors(
    warning: Color(0xFFEF6C00),
    warningContainer: Color(0xFFFFF3E0),
    onWarning: Color(0xFFFFFFFF),
    onWarningContainer: Color(0xFFE65100),
  );

  @override
  AppColors copyWith({
    Color? warning,
    Color? warningContainer,
    Color? onWarning,
    Color? onWarningContainer,
  }) {
    return AppColors(
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarning: onWarning ?? this.onWarning,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      onWarningContainer: Color.lerp(
        onWarningContainer,
        other.onWarningContainer,
        t,
      )!,
    );
  }
}

/// Fabryki motywów z zarejestrowanym AppColors extension.
class AppTheme {
  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: Colors.indigo,
    extensions: const [AppColors._defaults],
  );

  static ThemeData light() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: Colors.indigo,
    extensions: const [AppColors._defaults],
  );
}

import 'package:flutter/material.dart';

/// Tokeny spacing — wierne mapowanie z istniejących użyć w projekcie.
/// Nie zmieniaj wartości bez świadomej decyzji wizualnej.
class Spacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}

/// Semantyczne kolory recovery/warning (banner "Odpowiedź przerwana",
/// utracony klucz API). Cztery sloty, jeden zestaw per motyw.
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

  // Wariant jasny — odwzorowanie obecnych Colors.orange.shade*.
  static const _light = AppColors(
    warning: Color(0xFFEF6C00),
    warningContainer: Color(0xFFFFF3E0),
    onWarning: Color(0xFFFFFFFF),
    onWarningContainer: Color(0xFFE65100),
  );

  // Wariant ciemny — zweryfikowany empirycznie na żywym ekranie (sub-commit 1):
  // ciepły brąz jako tło bannera + jasny amber jako tekst/ikona, dobry kontrast
  // na ciemnym surface bez krzyczenia.
  static const _dark = AppColors(
    warning: Color(0xFFFFB74D),
    warningContainer: Color(0xFF3D2E1F),
    onWarning: Color(0xFF000000),
    onWarningContainer: Color(0xFFFFCC80),
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

/// Fabryki motywów z zarejestrowanym AppColors extension i wzmocnionym
/// AppBar (M3 default zlewa AppBar z surface w trybie dark; wymuszamy
/// surfaceContainer dla wizualnej hierarchii).
class AppTheme {
  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(backgroundColor: scheme.surfaceContainer),
      extensions: const [AppColors._dark],
    );
  }

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(backgroundColor: scheme.surfaceContainer),
      extensions: const [AppColors._light],
    );
  }
}

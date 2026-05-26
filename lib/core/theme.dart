import 'package:flutter/material.dart';

// Placeholder do design systemu — atramentowy granat. Zmiana = jedna stała.
const _seed = Color(0xFF283593);

ThemeData buildLightTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: _seed),
);

ThemeData buildDarkTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: Brightness.dark,
  ),
);

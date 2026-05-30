import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:atrament_app/core/logging/log_buffer.dart';
import 'package:atrament_app/core/providers/theme_mode_provider.dart';
import 'package:atrament_app/core/theme.dart';
import 'package:atrament_app/features/chat/presentation/chat_screen.dart';
import 'package:atrament_app/features/chat/presentation/chats_list_screen.dart';
import 'package:atrament_app/l10n/app_localizations.dart';

void main() {
  // Inicjalizacja bindings przed ustawieniem global error handlers — wymagane
  // by FlutterError i PlatformDispatcher były gotowe.
  WidgetsFlutterBinding.ensureInitialized();

  // ──────────────────────────────────────────────────────────────────────────
  // Global error handlers — łapią unhandled exceptions i routują do LogBuffer
  // jako crash entries. User zobaczy je w Diagnostyka → Awarie i może
  // świadomie wysłać przez share intent (Opcja A z Sesji D: lokalne crash
  // logging z opcją wysłania, zgodne z positioning "brak telemetrii").
  //
  // Dwa handlery są potrzebne razem:
  // - FlutterError.onError: synchronous errors z Flutter framework
  //   (widgets, render pipeline, gestures)
  // - PlatformDispatcher.onError: asynchronous errors poza Flutter framework
  //   (Dart isolate-level uncaught exceptions, async errors)
  //
  // Auto-redaction w LogBuffer._add() filtruje wrażliwe wzorce ZANIM zapisze,
  // więc nawet stack trace zawierający URL z credentials zostanie zredagowany.
  // ──────────────────────────────────────────────────────────────────────────

  FlutterError.onError = (FlutterErrorDetails details) {
    LogBuffer().crash(
      'FlutterError: ${details.exceptionAsString()}\n'
      'Library: ${details.library}\n'
      'Context: ${details.context}\n'
      'Stack:\n${details.stack}',
    );
    // Zachowaj oryginalne zachowanie Flutter (czerwone screen w debug,
    // print do konsoli debug) — handler dodaje LogBuffer, nie zastępuje.
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    LogBuffer().crash('PlatformError: $error\nStack:\n$stack');
    // Return true = error marked as handled (zapobiega crashom appki gdy to
    // możliwe). False zostawiłoby Dart runtime przewrócić appkę.
    return true;
  };

  runApp(const ProviderScope(child: AtramentApp()));
}

class AtramentApp extends ConsumerWidget {
  const AtramentApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'Atrament',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      // i18n: PL gdy system PL, else EN. Sekcja 7.9 manifestu.
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pl'), Locale('en')],
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (deviceLocale?.languageCode == 'pl') return const Locale('pl');
        return const Locale('en');
      },
      // Routing: '/' = lista, '/chat' = czat. Profile-flow nadal na
      // MaterialPageRoute z chats_list — tracked TODO przy refactorze profile.
      initialRoute: '/',
      routes: {
        '/': (_) => const ChatsListScreen(),
        '/chat': (_) => const ChatScreen(),
      },
    );
  }
}

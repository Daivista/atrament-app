import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atrament_app/core/logging/log_buffer.dart';
import 'package:atrament_app/core/providers/theme_mode_provider.dart';
import 'package:atrament_app/core/theme.dart';
import 'package:atrament_app/features/chat/presentation/chat_screen.dart';
import 'package:atrament_app/features/chat/presentation/chats_list_screen.dart';
import 'package:atrament_app/features/onboarding/presentation/onboarding_screen.dart';
import 'package:atrament_app/l10n/app_localizations.dart';

Future<void> main() async {
  // Inicjalizacja bindings przed ustawieniem global error handlers — wymagane
  // by FlutterError i PlatformDispatcher były gotowe.
  WidgetsFlutterBinding.ensureInitialized();

  // ──────────────────────────────────────────────────────────────────────────
  // Global error handlers (Sesja D) — łapią unhandled exceptions i routują
  // do LogBuffer jako crash entries. User zobaczy je w Diagnostyka → Awarie
  // i może świadomie wysłać przez share intent.
  // ──────────────────────────────────────────────────────────────────────────

  FlutterError.onError = (FlutterErrorDetails details) {
    LogBuffer().crash(
      'FlutterError: ${details.exceptionAsString()}\n'
      'Library: ${details.library}\n'
      'Context: ${details.context}\n'
      'Stack:\n${details.stack}',
    );
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    LogBuffer().crash('PlatformError: $error\nStack:\n$stack');
    return true;
  };

  // ──────────────────────────────────────────────────────────────────────────
  // Sesja H — onboarding flow check. Pierwsze uruchomienie aplikacji =
  // hasSeenOnboarding flag jest null (default false), więc app startuje
  // od /onboarding. Po skip lub Get started OnboardingScreen ustawia flag
  // na true i pushReplacementNamed('/'). Drugie uruchomienie czyta true,
  // initialRoute = '/' (ChatsListScreen) — onboarding pomijany.
  //
  // SharedPreferences.getInstance() jest szybkie (<10ms), więc async
  // bootstrap nie wprowadza zauważalnego boot time delay.
  // ──────────────────────────────────────────────────────────────────────────

  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
  LogBuffer().info(
    'app',
    'Bootstrap: hasSeenOnboarding=$hasSeenOnboarding',
  );

  runApp(
    ProviderScope(
      child: AtramentApp(skipOnboarding: hasSeenOnboarding),
    ),
  );
}

class AtramentApp extends ConsumerWidget {
  final bool skipOnboarding;
  const AtramentApp({super.key, required this.skipOnboarding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'Atrament',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
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
      // Sesja H: initial route zależy od flag onboardingu. Jeśli user widział
      // onboarding (flag=true) → start od ChatsListScreen. Jeśli nie → start
      // od OnboardingScreen, który po complete robi pushReplacementNamed('/')
      // żeby usunąć onboarding z navigation stack.
      initialRoute: skipOnboarding ? '/' : '/onboarding',
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/': (_) => const ChatsListScreen(),
        '/chat': (_) => const ChatScreen(),
      },
    );
  }
}

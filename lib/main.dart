import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:atrament_app/core/providers/theme_mode_provider.dart';
import 'package:atrament_app/core/theme.dart';
import 'package:atrament_app/features/chat/presentation/chat_screen.dart';
import 'package:atrament_app/features/chat/presentation/chats_list_screen.dart';
import 'package:atrament_app/l10n/app_localizations.dart';

void main() => runApp(const ProviderScope(child: AtramentApp()));

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

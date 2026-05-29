import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:atrament_app/core/theme.dart';
import 'package:atrament_app/features/chat/presentation/chat_screen.dart';
import 'package:atrament_app/features/chat/presentation/chats_list_screen.dart';
import 'package:atrament_app/l10n/app_localizations.dart';

void main() => runApp(const ProviderScope(child: AtramentApp()));

class AtramentApp extends StatelessWidget {
  const AtramentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atrament',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
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
      // Routing: '/' = lista, '/chat' = czat. Route '/chat' jest zdefiniowana
      // ale w sub-commit 1 chats_list nadal używa Navigator.push(MaterialPageRoute);
      // sub-commit 2 przepnie go na pushNamed.
      initialRoute: '/',
      routes: {
        '/': (_) => const ChatsListScreen(),
        '/chat': (_) => const ChatScreen(),
      },
    );
  }
}

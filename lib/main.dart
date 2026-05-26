import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'features/profiles/presentation/profiles_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AtramentApp()));
}

class AtramentApp extends StatelessWidget {
  const AtramentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atrament',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      home: const ProfilesScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'data/database/database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();

  // Test runtime: wstaw jeden profil
  await db
      .into(db.profiles)
      .insert(
        ProfilesCompanion.insert(
          id: const Uuid().v4(),
          name: 'Test LM Studio',
          type: 'openai_compat',
          baseUrl: 'http://192.168.1.10:1234',
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

  // Odczytaj wszystkie profile z bazy
  final profiles = await db.select(db.profiles).get();
  debugPrint('=== PROFILE W BAZIE: ${profiles.length} ===');
  for (final pf in profiles) {
    debugPrint('  ${pf.name} @ ${pf.baseUrl}');
  }

  runApp(MyApp(profileCount: profiles.length));
}

class MyApp extends StatelessWidget {
  final int profileCount;
  const MyApp({super.key, required this.profileCount});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atrament',
      home: Scaffold(
        appBar: AppBar(title: const Text('Atrament — test bazy')),
        body: Center(
          child: Text(
            'Profili w bazie: $profileCount',
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}

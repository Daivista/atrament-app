import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: TestApp()));
}

class TestApp extends ConsumerWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    return MaterialApp(
      title: 'Atrament',
      home: Scaffold(
        appBar: AppBar(title: const Text('Test Riverpod')),
        body: FutureBuilder(
          future: db.select(db.profiles).get(),
          builder: (context, snap) {
            if (snap.hasError) {
              return Center(child: Text('❌ ${snap.error}'));
            }
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return Center(
              child: Text(
                '✅ Riverpod + baza działają\nProfili w bazie: ${snap.data!.length}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, color: Colors.green),
              ),
            );
          },
        ),
      ),
    );
  }
}

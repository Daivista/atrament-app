import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/providers.dart';
import 'features/profiles/data/profile_providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: TestApp()));
}

class TestApp extends ConsumerWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Test etap 1: API + Repository')),
        body: FutureBuilder<String>(
          future: _runTest(ref),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            return Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Text(
                  snap.hasError ? '❌ ${snap.error}' : (snap.data ?? ''),
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<String> _runTest(WidgetRef ref) async {
    final buf = StringBuffer();
    try {
      final api = ref.read(apiClientProvider);
      final models = await api.fetchModels('http://10.0.2.2:1234');
      buf.writeln('✅ API: pobrano ${models.length} modeli');
      buf.writeln('   pierwszy: ${models.first}\n');

      final repo = ref.read(profileRepositoryProvider);
      final id = await repo.saveProfile(
        name: 'LM Studio test',
        baseUrl: 'http://10.0.2.2:1234',
        type: 'openai_compat',
        apiKey: 'sk-test-klucz',
      );
      buf.writeln('✅ Repository: zapisano profil ${id.substring(0, 8)}...');

      final all = await repo.getAllProfiles();
      buf.writeln('✅ Profili w bazie: ${all.length}');

      final key = await repo.getApiKey(id);
      buf.writeln(
        '✅ Klucz: ${key == "sk-test-klucz" ? "odczytany poprawnie" : "BŁĄD ($key)"}',
      );

      await repo.deleteProfile(id);
      final afterDelete = await repo.getAllProfiles();
      buf.writeln('✅ Po usunięciu profili: ${afterDelete.length}\n');
      buf.writeln('Etap 1 OK — warstwa nie-UI (API + repository) działa.');
    } catch (e) {
      buf.writeln('❌ BŁĄD: $e');
    }
    return buf.toString();
  }
}

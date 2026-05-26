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
        appBar: AppBar(title: const Text('Test: edycja + aktywny profil')),
        body: FutureBuilder<String>(
          future: _test(ref),
          builder: (c, s) => s.connectionState != ConnectionState.done
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Text(
                      s.hasError ? '❌ ${s.error}' : s.data ?? '',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Future<String> _test(WidgetRef ref) async {
    final b = StringBuffer();
    final repo = ref.read(profileRepositoryProvider);
    try {
      final id = await repo.saveProfile(
        name: 'Przed edycją',
        baseUrl: 'http://10.0.2.2:1234',
        type: 'openai_compat',
      );
      b.writeln('✅ Zapisano profil ${id.substring(0, 8)}');

      await repo.setActiveProfileId(id);
      final active = await repo.watchActiveProfileId().first;
      b.writeln('✅ Aktywny: ${active == id ? "ustawiony poprawnie" : "BŁĄD"}');

      await repo.updateProfile(
        id: id,
        name: 'Po edycji',
        baseUrl: 'http://10.0.2.2:5678',
      );
      final all = await repo.getAllProfiles();
      final edited = all.firstWhere((p) => p.id == id);
      b.writeln('✅ Edycja: nazwa="${edited.name}", url="${edited.baseUrl}"');

      await repo.deleteProfile(id);
      final afterDel = await repo.getAllProfiles();
      final activeAfter = await repo.watchActiveProfileId().first;
      b.writeln(
        '✅ Po usunięciu: profili=${afterDel.length}, '
        'aktywny=${activeAfter == null ? "wyczyszczony" : "BŁĄD ($activeAfter)"}',
      );
      b.writeln('\nWarstwa 1 OK — edycja + aktywny profil działają.');
    } catch (e) {
      b.writeln('❌ BŁĄD: $e');
    }
    return b.toString();
  }
}

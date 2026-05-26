import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/profile_providers.dart';
import 'add_profile_screen.dart';

class ProfilesScreen extends ConsumerWidget {
  const ProfilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(profilesListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Atrament — serwery')),
      body: profilesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Błąd: $e')),
        data: (profiles) {
          if (profiles.isEmpty) return const _EmptyState();
          return ListView.builder(
            itemCount: profiles.length,
            itemBuilder: (context, i) {
              final p = profiles[i];
              return ListTile(
                leading: const Icon(Icons.dns),
                title: Text(p.name),
                subtitle: Text(p.baseUrl),
                trailing: Text(
                  p.type,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AddProfileScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Dodaj serwer'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dns_outlined, size: 64, color: cs.outline),
          const SizedBox(height: 16),
          Text('Brak serwerów', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Dodaj swój pierwszy serwer LLM (LM Studio, Ollama…), '
              'żeby zacząć rozmowę.',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

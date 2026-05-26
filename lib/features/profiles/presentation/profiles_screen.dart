import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../data/profile_providers.dart';
import 'add_profile_screen.dart';

class ProfilesScreen extends ConsumerWidget {
  const ProfilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(profilesListProvider);
    final activeId = ref.watch(activeProfileIdProvider).value;

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
              final isActive = p.id == activeId;
              return ListTile(
                isThreeLine: p.apiKeyNeedsReentry,
                leading: Icon(
                  isActive ? Icons.star : Icons.dns,
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(p.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.baseUrl),
                    if (p.apiKeyNeedsReentry)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber,
                              size: 16,
                              color: Colors.orange.shade800,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Klucz API utracony — wybierz Edytuj, by wpisać ponownie',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) => _onAction(context, ref, v, p),
                  itemBuilder: (_) => [
                    if (!isActive)
                      const PopupMenuItem(
                        value: 'activate',
                        child: Text('Ustaw jako aktywny'),
                      ),
                    if (isActive)
                      const PopupMenuItem(
                        value: 'deactivate',
                        child: Text('Usuń oznaczenie aktywnego'),
                      ),
                    const PopupMenuItem(value: 'edit', child: Text('Edytuj')),
                    const PopupMenuItem(value: 'delete', child: Text('Usuń')),
                  ],
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

  Future<void> _onAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    Profile p,
  ) async {
    final repo = ref.read(profileRepositoryProvider);
    switch (action) {
      case 'activate':
        await repo.setActiveProfileId(p.id);
      case 'deactivate':
        await repo.clearActiveProfile();
      case 'edit':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => AddProfileScreen(editing: p)));
      case 'delete':
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Usunąć serwer?'),
            content: Text(
              'Profil „${p.name}" zostanie usunięty wraz z kluczem API. '
              'Tej operacji nie można cofnąć.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Anuluj'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Usuń'),
              ),
            ],
          ),
        );
        if (ok == true) await repo.deleteProfile(p.id);
    }
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

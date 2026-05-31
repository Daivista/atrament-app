import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../core/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../data/profile_providers.dart';

class ProfilesScreen extends ConsumerWidget {
  const ProfilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final appColors = Theme.of(context).extension<AppColors>()!;
    final profilesAsync = ref.watch(profilesListProvider);
    final activeId = ref.watch(activeProfileIdProvider).value;

    return Scaffold(
      // Sub-ekran (Navigator.pushNamed z chats_list) — tytuł kontekstowy
      // ("Serwery"), nie powtarzanie marki ("Atrament"). Konwencja jak
      // chats_list: główny ekran = brand name, sub-ekran = co user teraz robi.
      appBar: AppBar(title: Text(loc.profilesScreenTitle)),
      body: profilesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(loc.profilesScreenError(e))),
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
                              color: appColors.warning,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                loc.profilesScreenKeyLost,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: appColors.warning,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) => _onAction(context, ref, v, p, loc),
                  itemBuilder: (_) => [
                    if (!isActive)
                      PopupMenuItem(
                        value: 'activate',
                        child: Text(loc.profilesScreenActionActivate),
                      ),
                    if (isActive)
                      PopupMenuItem(
                        value: 'deactivate',
                        child: Text(loc.profilesScreenActionDeactivate),
                      ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(loc.profilesScreenActionEdit),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(loc.commonDelete),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        // Profile-flow refactor: named route '/profile' bez arguments =
        // tryb new w AddProfileScreen (onGenerateRoute w main.dart
        // przekaże editing=null).
        onPressed: () => Navigator.of(context).pushNamed('/profile'),
        icon: const Icon(Icons.add),
        label: Text(loc.profilesScreenAddProfile),
      ),
    );
  }

  Future<void> _onAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    Profile p,
    AppLocalizations loc,
  ) async {
    final repo = ref.read(profileRepositoryProvider);
    switch (action) {
      case 'activate':
        await repo.setActiveProfileId(p.id);
      case 'deactivate':
        await repo.clearActiveProfile();
      case 'edit':
        // Profile-flow refactor: named route '/profile' z arguments=Profile
        // = tryb edit (onGenerateRoute w main.dart rozpakuje editing=p).
        Navigator.of(context).pushNamed('/profile', arguments: p);
      case 'delete':
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(loc.profilesScreenDeleteConfirmTitle),
            content: Text(
              loc.profilesScreenDeleteConfirmContent(p.name),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(loc.commonCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(loc.commonDelete),
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
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dns_outlined, size: 64, color: cs.outline),
          const SizedBox(height: 16),
          Text(
            loc.profilesScreenEmpty,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              loc.profilesScreenEmptyHint,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

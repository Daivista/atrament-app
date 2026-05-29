import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../profiles/presentation/profiles_screen.dart';
import '../data/chat_providers.dart';
import 'chat_controller.dart';

class ChatsListScreen extends ConsumerWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final chatsAsync = ref.watch(chatsListProvider);
    return Scaffold(
      appBar: AppBar(
        // 'Atrament' jest nazwą marki — nie tłumaczone celowo.
        title: const Text('Atrament'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dns),
            tooltip: loc.chatsListServersTooltip,
            // ProfilesScreen i AddProfileScreen nie są jeszcze w main.dart routes —
            // refactor profili poza scope Kroku 2, świadoma niespójność tymczasowa.
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProfilesScreen())),
          ),
        ],
      ),
      body: chatsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(loc.chatsListError(e))),
        data: (chats) {
          if (chats.isEmpty) {
            return EmptyState(
              icon: Icons.forum_outlined,
              title: loc.chatsListEmpty,
              body: loc.chatsListEmptyHint,
            );
          }
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, i) {
              final c = chats[i];
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.chat_bubble_outline),
                ),
                title: Text(
                  c.title ?? loc.commonUnnamedChat,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(_formatDate(c.updatedAt, loc)),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) => _onAction(context, ref, v, c, loc),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'rename',
                      child: Text(loc.chatsListRename),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(loc.commonDelete),
                    ),
                  ],
                ),
                onTap: () => _openChat(context, ref, c.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _newChat(context, ref),
        icon: const Icon(Icons.add_comment_outlined),
        label: Text(loc.commonNewChat),
      ),
    );
  }

  Future<void> _openChat(
    BuildContext context,
    WidgetRef ref,
    String chatId,
  ) async {
    await ref.read(chatControllerProvider.notifier).loadChat(chatId);
    if (!context.mounted) return;
    Navigator.of(context).pushNamed('/chat');
  }

  void _newChat(BuildContext context, WidgetRef ref) {
    ref.read(chatControllerProvider.notifier).newChat();
    Navigator.of(context).pushNamed('/chat');
  }

  Future<void> _onAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    Chat c,
    AppLocalizations loc,
  ) async {
    switch (action) {
      case 'rename':
        final newName = await _askName(context, c.title ?? '', loc);
        if (newName != null) {
          await ref
              .read(messageRepositoryProvider)
              .updateChatTitle(c.id, newName);
        }
      case 'delete':
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(loc.chatsListDeleteConfirmTitle),
            content: Text(
              loc.chatsListDeleteConfirmContent(c.title ?? loc.commonUnnamedChat),
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
        if (ok == true) {
          await ref.read(messageRepositoryProvider).deleteChat(c.id);
        }
    }
  }

  Future<String?> _askName(
    BuildContext context,
    String current,
    AppLocalizations loc,
  ) {
    final ctrl = TextEditingController(text: current);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.chatTitleEditDialog),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: Text(loc.commonSave),
          ),
        ],
      ),
    );
  }

  /// Format daty: dziś → "Dziś HH:MM" / "Today HH:MM"; inny dzień → DD.MM.YYYY HH:MM.
  /// Tracked TODO: pełne formatowanie per locale przez intl DateFormat — obecnie
  /// format DD.MM.YYYY hardcoded (międzynarodowy, nie US MM/DD).
  String _formatDate(int millis, AppLocalizations loc) {
    final d = DateTime.fromMillisecondsSinceEpoch(millis);
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return '${loc.chatsListToday} ${_two(d.hour)}:${_two(d.minute)}';
    }
    return '${_two(d.day)}.${_two(d.month)}.${d.year} ${_two(d.hour)}:${_two(d.minute)}';
  }

  String _two(int n) => n.toString().padLeft(2, '0');
}

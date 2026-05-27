import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../profiles/presentation/profiles_screen.dart';
import '../data/chat_providers.dart';
import 'chat_controller.dart';
import 'chat_screen.dart';

class ChatsListScreen extends ConsumerWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(chatsListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atrament'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dns),
            tooltip: 'Serwery',
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProfilesScreen())),
          ),
        ],
      ),
      body: chatsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Błąd: $e')),
        data: (chats) {
          if (chats.isEmpty) return const _EmptyState();
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, i) {
              final c = chats[i];
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.chat_bubble_outline),
                ),
                title: Text(
                  c.title ?? 'Bez nazwy',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(_formatDate(c.updatedAt)),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) => _onAction(context, ref, v, c),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'rename', child: Text('Zmień nazwę')),
                    PopupMenuItem(value: 'delete', child: Text('Usuń')),
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
        label: const Text('Nowa rozmowa'),
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
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ChatScreen()));
  }

  void _newChat(BuildContext context, WidgetRef ref) {
    ref.read(chatControllerProvider.notifier).newChat();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ChatScreen()));
  }

  Future<void> _onAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    Chat c,
  ) async {
    switch (action) {
      case 'rename':
        final newName = await _askName(context, c.title ?? '');
        if (newName != null) {
          await ref
              .read(messageRepositoryProvider)
              .updateChatTitle(c.id, newName);
        }
      case 'delete':
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Usunąć rozmowę?'),
            content: Text(
              'Rozmowa „${c.title ?? "bez nazwy"}" zostanie usunięta wraz ze wszystkimi wiadomościami.',
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
        if (ok == true) {
          await ref.read(messageRepositoryProvider).deleteChat(c.id);
        }
    }
  }

  Future<String?> _askName(BuildContext context, String current) {
    final ctrl = TextEditingController(text: current);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Zmień nazwę rozmowy'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Anuluj'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: const Text('Zapisz'),
          ),
        ],
      ),
    );
  }

  String _formatDate(int millis) {
    final d = DateTime.fromMillisecondsSinceEpoch(millis);
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return 'Dziś ${_two(d.hour)}:${_two(d.minute)}';
    }
    return '${_two(d.day)}.${_two(d.month)}.${d.year} ${_two(d.hour)}:${_two(d.minute)}';
  }

  String _two(int n) => n.toString().padLeft(2, '0');
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
          Icon(Icons.forum_outlined, size: 64, color: cs.outline),
          const SizedBox(height: 16),
          Text('Brak rozmów', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Stuknij „Nowa rozmowa", by zacząć pierwszą.',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

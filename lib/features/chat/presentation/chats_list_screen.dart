import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../core/providers/theme_mode_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../diagnostics/presentation/diagnostics_screen.dart';
import '../data/chat_providers.dart';
import 'chat_controller.dart';

class ChatsListScreen extends ConsumerWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final chatsAsync = ref.watch(chatsListProvider);
    final themeMode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(
        // 'Atrament' jest nazwą marki — nie tłumaczone celowo.
        title: const Text('Atrament'),
        actions: [
          IconButton(
            icon: Icon(_themeIcon(themeMode)),
            tooltip: _themeTooltip(themeMode, loc),
            onPressed: () =>
                ref.read(themeModeProvider.notifier).cycle(),
          ),
          IconButton(
            icon: const Icon(Icons.dns),
            tooltip: loc.chatsListServersTooltip,
            // Profile-flow refactor: named route '/profiles' zamiast
            // MaterialPageRoute. Konsystentne z chat-flow nawigacją.
            onPressed: () => Navigator.of(context).pushNamed('/profiles'),
          ),
          // Overflow menu na końcu — akcje rzadziej używane (diagnostyka,
          // w przyszłości settings/about). Konwencja Material Design:
          // primary actions = bezpośrednie ikony, secondary = popup menu.
          PopupMenuButton<String>(
            tooltip: loc.commonMoreMenu,
            onSelected: (v) => _onMenuAction(context, v),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'diagnostics',
                child: Row(
                  children: [
                    const Icon(Icons.bug_report_outlined, size: 20),
                    const SizedBox(width: 12),
                    Text(loc.diagnosticsTitle),
                  ],
                ),
              ),
            ],
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

  /// Ikona aktualnego trybu motywu. Cycle: system → light → dark.
  IconData _themeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
    }
  }

  /// Tooltip pokazuje *aktualny* tryb (nie następny). User wie co jest teraz,
  /// kliknięcie cyklicznie zmienia na kolejny stan.
  String _themeTooltip(ThemeMode mode, AppLocalizations loc) {
    switch (mode) {
      case ThemeMode.system:
        return loc.themeModeSystem;
      case ThemeMode.light:
        return loc.themeModeLight;
      case ThemeMode.dark:
        return loc.themeModeDark;
    }
  }

  void _onMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'diagnostics':
        // Diagnostics nie jest w main.dart routes — tracked TODO, osobny
        // refactor (poza scope profile-flow). MaterialPageRoute tymczasowo.
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DiagnosticsScreen()),
        );
    }
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

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
  /// Tablet split view mode flag. When true:
  /// - tap chat or FAB does NOT push '/chat' route
  /// - instead calls [onChatOpened] callback so parent
  ///   [AdaptiveHomeScaffold] can show right pane
  ///
  /// Default false (mobile flow unchanged).
  final bool inSplitView;

  /// Called after tap chat / FAB in split view mode. Used by parent
  /// [AdaptiveHomeScaffold] to mark right pane as active.
  final VoidCallback? onChatOpened;

  /// Called when user taps sidebar collapse button. Only relevant in
  /// split view mode — parent [AdaptiveHomeScaffold] toggles sidebar
  /// visibility. AppBar leading IconButton shown only when this
  /// callback is provided AND inSplitView=true.
  final VoidCallback? onToggleSidebar;

  const ChatsListScreen({
    super.key,
    this.inSplitView = false,
    this.onChatOpened,
    this.onToggleSidebar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final chatsAsync = ref.watch(chatsListProvider);
    final themeMode = ref.watch(themeModeProvider);
    final showCollapseButton = inSplitView && onToggleSidebar != null;
    return Scaffold(
      appBar: AppBar(
        // Disable automatic back arrow — w mobile mode '/' to home (canPop=false
        // po onboarding fix), w split view route '/' też nie ma canPop. Wprost
        // wyłączenie żeby implicit leading nigdy nie zaskoczył.
        automaticallyImplyLeading: false,
        // Tablet collapsible sidebar: leading menu_open icon w split view
        // pozwala user collapse sidebar (lista chats znika, chat full width).
        leading: showCollapseButton
            ? IconButton(
                icon: const Icon(Icons.menu_open),
                tooltip: loc.tabletSidebarCollapse,
                onPressed: onToggleSidebar,
              )
            : null,
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
                onTap: () => _openChat(context, ref, c.id, loc),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _newChat(context, ref, loc),
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

  /// Tap chat from list. Two flows:
  ///
  /// **Mobile**: loadChat + pushNamed('/chat') — standard push as before.
  ///
  /// **Tablet split view**: loadChat + onChatOpened() callback — no push,
  /// AdaptiveHomeScaffold reactively shows ChatScreen in right pane.
  ///
  /// **Guard**: if any chat currently streaming, show SnackBar feedback
  /// and skip. Fixes Sesja G discovered edge case (concurrent navigation/
  /// streaming) — applies uniformly to mobile AND tablet because mobile
  /// users also experienced this confusion silently.
  Future<void> _openChat(
    BuildContext context,
    WidgetRef ref,
    String chatId,
    AppLocalizations loc,
  ) async {
    final chatState = ref.read(chatControllerProvider);
    if (chatState.isStreaming) {
      _showStreamingSnackBar(context, loc);
      return;
    }
    await ref.read(chatControllerProvider.notifier).loadChat(chatId);
    if (!context.mounted) return;
    if (inSplitView) {
      onChatOpened?.call();
    } else {
      Navigator.of(context).pushNamed('/chat');
    }
  }

  /// Tap FAB "Nowa rozmowa". Two flows:
  ///
  /// **Mobile**: newChat() + pushNamed('/chat') — push new empty chat screen.
  ///
  /// **Tablet split view**: newChat() + onChatOpened() — show empty chat
  /// in right pane, no push.
  ///
  /// **Guard**: if any chat currently streaming, show SnackBar feedback
  /// and skip. Consistent with _openChat.
  void _newChat(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations loc,
  ) {
    final chatState = ref.read(chatControllerProvider);
    if (chatState.isStreaming) {
      _showStreamingSnackBar(context, loc);
      return;
    }
    ref.read(chatControllerProvider.notifier).newChat();
    if (inSplitView) {
      onChatOpened?.call();
    } else {
      Navigator.of(context).pushNamed('/chat');
    }
  }

  /// Sesja G discovered edge case fix: visible UX feedback gdy user próbuje
  /// nawigować do innej rozmowy podczas trwającego streaming. Aktualnie
  /// loadChat ma guard if (state.isStreaming) return; — defensive (zapobiega
  /// state corruption). SnackBar tu daje user wizualną odpowiedź "dlaczego
  /// nic się nie stało po kliknięciu".
  void _showStreamingSnackBar(BuildContext context, AppLocalizations loc) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loc.chatStreamingInProgress),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
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

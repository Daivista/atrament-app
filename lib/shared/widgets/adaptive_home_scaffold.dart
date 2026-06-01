import 'package:flutter/material.dart';
import '../../features/chat/presentation/chat_screen.dart';
import '../../features/chat/presentation/chats_list_screen.dart';
import '../../l10n/app_localizations.dart';
import 'empty_state.dart';

/// Adaptive layout root for primary navigation flow ('/' route).
///
/// **Mobile** (width < 720dp): standalone [ChatsListScreen], tap chat
/// pushes '/chat' route (Navigator stack as before).
///
/// **Tablet split view** (width >= 720dp): two panes side-by-side —
/// [ChatsListScreen] in left (35%), [ChatScreen] or [_TabletEmptyPane] in
/// right (65%). Tap chat in left pane only updates ChatController state
/// without pushing route — right pane reactively re-renders via ref.watch.
///
/// **Collapsible sidebar** (tablet only): user can toggle sidebar via
/// IconButton in AppBar (menu_open icon when expanded, menu icon when
/// collapsed). When collapsed, sidebar hides and right pane takes full
/// width. Critical for tablet portrait (~800dp) where 35% list leaves
/// chat content only ~520dp — collapse gives chat full ~800dp width.
/// State volatile (per session, not persisted) — F2 polish may add
/// SharedPreferences persistence if user feedback indicates need.
///
/// Breakpoint 720dp is intentional compromise:
/// - 600dp (Material medium): too aggressive, tablet portrait gives cramped
///   split with both panes ~300dp wide
/// - 720dp (this): sweet spot — tablet landscape always splits, tablet
///   portrait splits if device is >= 720dp wide (most modern tablets)
/// - 840dp (Material expanded): too conservative, tablet portrait shows
///   single pane despite ample screen real estate
class AdaptiveHomeScaffold extends StatefulWidget {
  const AdaptiveHomeScaffold({super.key});

  @override
  State<AdaptiveHomeScaffold> createState() => _AdaptiveHomeScaffoldState();
}

class _AdaptiveHomeScaffoldState extends State<AdaptiveHomeScaffold> {
  /// Whether right pane should show ChatScreen or _TabletEmptyPane.
  /// Set true after first user interaction (tap chat from list or FAB
  /// "Nowa rozmowa"). Default false so user sees explicit placeholder
  /// on tablet first open instead of empty ChatScreen with confusing
  /// "Write a message to start" hint.
  bool _showChatPane = false;

  /// Whether sidebar is collapsed (left pane hidden, right pane full width).
  /// Default false (expanded). User toggles via IconButton in AppBar.
  /// Volatile state — resets to expanded on app restart.
  bool _sidebarCollapsed = false;

  void _markChatPaneActive() {
    if (!_showChatPane) {
      setState(() => _showChatPane = true);
    }
  }

  void _toggleSidebar() {
    setState(() => _sidebarCollapsed = !_sidebarCollapsed);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSplit = constraints.maxWidth >= 720;
        if (!isSplit) {
          // Mobile path — standalone ChatsListScreen, tap pushes new route.
          // Identical to pre-tablet behavior. No regression possible.
          return const ChatsListScreen();
        }

        // Tablet split view. Right pane content (ChatScreen lub
        // _TabletEmptyPane) jest taki sam dla obu layoutów (expanded i
        // collapsed) — różnica jest tylko czy sidebar (left pane) jest
        // widoczny. Przekazujemy sidebarCollapsed do right pane żeby
        // ChatScreen mogło renderować leading IconButton(menu) tylko
        // gdy collapsed (expand button).
        final rightPane = _showChatPane
            ? ChatScreen(
                inSplitView: true,
                sidebarCollapsed: _sidebarCollapsed,
                onToggleSidebar: _toggleSidebar,
              )
            : _TabletEmptyPane(
                sidebarCollapsed: _sidebarCollapsed,
                onToggleSidebar: _toggleSidebar,
              );

        // AnimatedSwitcher cross-fade między dwoma layout configurations.
        // 200ms easeInOut to Material 3 standard duration dla layout
        // transitions. KeyedSubtree wymagany żeby AnimatedSwitcher
        // rozpoznał że to dwa różne dzieci (Row vs single).
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          child: _sidebarCollapsed
              ? KeyedSubtree(
                  key: const ValueKey('collapsed'),
                  child: rightPane,
                )
              : KeyedSubtree(
                  key: const ValueKey('expanded'),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 35,
                        child: ChatsListScreen(
                          inSplitView: true,
                          onChatOpened: _markChatPaneActive,
                          onToggleSidebar: _toggleSidebar,
                        ),
                      ),
                      VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      Expanded(flex: 65, child: rightPane),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

/// Placeholder shown in right pane on tablet split view before user picks
/// or creates a chat. Scaffold with empty AppBar maintains visual alignment
/// with neighboring [ChatScreen] (which has its own AppBar with chat title).
///
/// When sidebar collapsed, AppBar leading shows IconButton(menu) to expand.
/// Otherwise no leading (sidebar visible, no toggle needed from this pane).
class _TabletEmptyPane extends StatelessWidget {
  final bool sidebarCollapsed;
  final VoidCallback onToggleSidebar;

  const _TabletEmptyPane({
    required this.sidebarCollapsed,
    required this.onToggleSidebar,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      // Empty AppBar — visually matches ChatScreen AppBar height so divider
      // line aligns across both panes. Title intentionally blank because
      // there's no chat context yet. Leading IconButton appears only when
      // sidebar is collapsed (to allow user to expand back).
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(''),
        leading: sidebarCollapsed
            ? IconButton(
                icon: const Icon(Icons.menu),
                tooltip: loc.tabletSidebarExpand,
                onPressed: onToggleSidebar,
              )
            : null,
      ),
      body: EmptyState(
        icon: Icons.chat_bubble_outline,
        title: loc.splitViewEmptyTitle,
        body: loc.splitViewEmptyBody,
      ),
    );
  }
}

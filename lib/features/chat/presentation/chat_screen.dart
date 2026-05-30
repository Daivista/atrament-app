import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import '../../../core/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/code_block.dart';
import '../../../shared/widgets/empty_state.dart';
import 'chat_controller.dart';
import 'chat_parameters_sheet.dart';
import 'report_response_dialog.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  /// Per-message expanded state dla sekcji rozumowania (Sesja F).
  final Set<int> _expandedReasoning = {};

  void _send() {
    final text = _input.text;
    if (text.trim().isEmpty) return;
    _input.clear();
    ref.read(chatControllerProvider.notifier).send(text);
  }

  Future<void> _editTitle() async {
    final loc = AppLocalizations.of(context);
    final chat = ref.read(chatControllerProvider);
    if (chat.chatId == null) return;
    final ctrl = TextEditingController(text: chat.title ?? '');
    final result = await showDialog<String>(
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
    if (result != null) {
      await ref.read(chatControllerProvider.notifier).updateTitle(result);
    }
  }

  void _copyMessage(String content) {
    final loc = AppLocalizations.of(context);
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loc.commonCopied),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _reportMessage(int messageIndex) {
    ReportResponseDialog.show(context, messageIndex);
  }

  /// Sesja G — regenerate triggered z PopupMenu w bańce ostatniej assistant
  /// message. Bez confirmation — Stop button pozwala przerwać w trakcie.
  /// MVP F1 replace approach: stara message znika z DB i state, nowa
  /// streamuje się dla tego samego user pytania.
  void _regenerateLastMessage() {
    ref.read(chatControllerProvider.notifier).regenerateLastAssistant();
  }

  void _toggleReasoning(int index) {
    setState(() {
      if (_expandedReasoning.contains(index)) {
        _expandedReasoning.remove(index);
      } else {
        _expandedReasoning.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final appColors = Theme.of(context).extension<AppColors>()!;
    final targetAsync = ref.watch(chatTargetProvider);
    final chat = ref.watch(chatControllerProvider);

    // Sesja F decyzja projektowa: TLDR-first UX. Po zakończeniu streaming
    // reasoning section AUTO-ZWIJA się (AnimatedSize smooth collapse) bo
    // mainstream user chce odpowiedzi, nie procesu myślowego. Power user
    // ma jeden tap (chevron) żeby zobaczyć tok rozumowania. Konsekwentne
    // z reload behavior — historic messages default collapsed.

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });

    final titleText = chat.title ??
        (chat.chatId == null ? loc.commonNewChat : loc.commonUnnamedChat);
    final serverName = targetAsync.maybeWhen(
      data: (t) => t?.profileName,
      orElse: () => null,
    );

    final lastIsPartial = chat.messages.isNotEmpty &&
        chat.messages.last.isPartial &&
        chat.messages.last.role == 'assistant' &&
        !chat.isStreaming;

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _editTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                titleText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 18),
              ),
              if (serverName != null)
                Text(
                  serverName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: loc.chatParametersTooltip,
            onPressed: () => ChatParametersSheet.show(context),
          ),
        ],
      ),
      body: targetAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _NoServer(error: '$e'),
        data: (target) {
          if (target == null) return const _NoServer();
          return Column(
            children: [
              Expanded(
                child: _MessageList(
                  scroll: _scroll,
                  chat: chat,
                  onCopyMessage: _copyMessage,
                  onReportMessage: _reportMessage,
                  onRegenerateLast: _regenerateLastMessage,
                  expandedReasoning: _expandedReasoning,
                  onToggleReasoning: _toggleReasoning,
                ),
              ),
              if (lastIsPartial)
                Container(
                  width: double.infinity,
                  color: appColors.warningContainer,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.md,
                    vertical: Spacing.sm,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.pause_circle_outline,
                        color: appColors.warning,
                        size: 18,
                      ),
                      const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: Text(
                          loc.chatResponseInterrupted,
                          style: TextStyle(color: appColors.onWarningContainer),
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: Text(loc.chatContinueButton),
                        onPressed: () => ref
                            .read(chatControllerProvider.notifier)
                            .continueLast(),
                      ),
                    ],
                  ),
                ),
              if (chat.error != null)
                Container(
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.errorContainer,
                  padding: const EdgeInsets.all(Spacing.sm),
                  child: Text(
                    chat.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              _Composer(
                input: _input,
                isStreaming: chat.isStreaming,
                onSend: _send,
                onStop: () => ref.read(chatControllerProvider.notifier).stop(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  final ScrollController scroll;
  final ChatState chat;
  final void Function(String content) onCopyMessage;
  final void Function(int messageIndex) onReportMessage;
  final VoidCallback onRegenerateLast;
  final Set<int> expandedReasoning;
  final void Function(int messageIndex) onToggleReasoning;

  const _MessageList({
    required this.scroll,
    required this.chat,
    required this.onCopyMessage,
    required this.onReportMessage,
    required this.onRegenerateLast,
    required this.expandedReasoning,
    required this.onToggleReasoning,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final showStreaming = chat.isStreaming ||
        chat.streamingContent.isNotEmpty ||
        chat.streamingReasoning.isNotEmpty;
    final itemCount = chat.messages.length + (showStreaming ? 1 : 0);

    if (itemCount == 0) {
      return Center(child: Text(loc.chatEmptyHint));
    }

    return ListView.builder(
      controller: scroll,
      padding: const EdgeInsets.all(Spacing.md),
      itemCount: itemCount,
      itemBuilder: (context, i) {
        if (i < chat.messages.length) {
          final m = chat.messages[i];
          final showMenu = m.role == 'assistant' && !m.isPartial;
          // Sesja G: Regeneruj dostępne TYLKO dla ostatniej assistant message
          // która jest non-partial non-streaming. Wcześniejsze historic
          // messages mają tylko Copy + Report (regen by wymagał branching).
          final isLast = i == chat.messages.length - 1;
          final canRegenerate = isLast && showMenu && !chat.isStreaming;
          return _Bubble(
            text: m.content,
            isUser: m.role == 'user',
            isPartial: m.isPartial,
            reasoning: m.reasoning ?? '',
            isReasoningExpanded: expandedReasoning.contains(i),
            onToggleReasoning: (m.reasoning != null && m.reasoning!.isNotEmpty)
                ? () => onToggleReasoning(i)
                : null,
            onCopy: showMenu ? () => onCopyMessage(m.content) : null,
            onReport: showMenu ? () => onReportMessage(i) : null,
            onRegenerate: canRegenerate ? onRegenerateLast : null,
          );
        }
        return _Bubble(
          text: chat.streamingContent.isEmpty && chat.isStreaming
              ? '…'
              : chat.streamingContent,
          isUser: false,
          reasoning: chat.streamingReasoning,
          streaming: chat.isStreaming,
        );
      },
    );
  }
}

class _Bubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final String reasoning;
  final bool streaming;
  final bool isPartial;
  final bool isReasoningExpanded;
  final VoidCallback? onToggleReasoning;
  final VoidCallback? onCopy;
  final VoidCallback? onReport;
  final VoidCallback? onRegenerate;

  const _Bubble({
    required this.text,
    required this.isUser,
    this.reasoning = '',
    this.streaming = false,
    this.isPartial = false,
    this.isReasoningExpanded = false,
    this.onToggleReasoning,
    this.onCopy,
    this.onReport,
    this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final body = text + (streaming ? ' ▋' : '');
    final showMenu = onCopy != null || onReport != null || onRegenerate != null;
    final hasReasoning = reasoning.isNotEmpty;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Opacity(
        opacity: isPartial ? 0.75 : 1.0,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: Spacing.xs),
          padding: const EdgeInsets.all(Spacing.md),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          decoration: BoxDecoration(
            color: isUser ? cs.primaryContainer : cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasReasoning) ...[
                _ReasoningSection(
                  reasoning: reasoning,
                  isExpanded: isReasoningExpanded,
                  streaming: streaming,
                  onToggle: onToggleReasoning,
                ),
                const SizedBox(height: Spacing.xs),
              ],
              if (isUser)
                Text(body)
              else
                GptMarkdown(
                  body,
                  codeBuilder: (context, name, code, closed) => CodeBlock(
                    language: name,
                    code: code,
                    closed: closed,
                  ),
                ),
              if (showMenu) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: PopupMenuButton<String>(
                      tooltip: loc.commonMoreMenu,
                      icon: Icon(
                        Icons.more_horiz,
                        size: 18,
                        color: cs.outline,
                      ),
                      padding: EdgeInsets.zero,
                      onSelected: (v) {
                        if (v == 'regenerate' && onRegenerate != null) {
                          onRegenerate!();
                        }
                        if (v == 'copy' && onCopy != null) onCopy!();
                        if (v == 'report' && onReport != null) onReport!();
                      },
                      itemBuilder: (_) => [
                        // Sesja G: Regeneruj na górze menu — najbardziej
                        // pro-active akcja (nowa generacja). Dostępna tylko
                        // dla ostatniej non-partial assistant message.
                        if (onRegenerate != null)
                          PopupMenuItem(
                            value: 'regenerate',
                            child: Row(
                              children: [
                                const Icon(Icons.refresh, size: 18),
                                const SizedBox(width: 12),
                                Text(loc.chatRegenerate),
                              ],
                            ),
                          ),
                        if (onCopy != null)
                          PopupMenuItem(
                            value: 'copy',
                            child: Row(
                              children: [
                                const Icon(Icons.copy_outlined, size: 18),
                                const SizedBox(width: 12),
                                Text(loc.commonCopy),
                              ],
                            ),
                          ),
                        if (onReport != null)
                          PopupMenuItem(
                            value: 'report',
                            child: Row(
                              children: [
                                const Icon(Icons.flag_outlined, size: 18),
                                const SizedBox(width: 12),
                                Text(loc.chatReportResponse),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Akordeon sekcji rozumowania (chain-of-thought) modeli reasoning-capable.
/// (Sesja F dopracowanie — bez zmian w Sesji G.)
class _ReasoningSection extends StatelessWidget {
  final String reasoning;
  final bool isExpanded;
  final bool streaming;
  final VoidCallback? onToggle;

  const _ReasoningSection({
    required this.reasoning,
    required this.isExpanded,
    required this.streaming,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final effectivelyExpanded = streaming || isExpanded;
    final canToggle = !streaming && onToggle != null;
    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: canToggle ? onToggle : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: cs.outlineVariant, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    const Text('🧠', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 6),
                    Text(
                      loc.chatReasoningLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    if (streaming) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: cs.primary,
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (!streaming)
                      AnimatedRotation(
                        turns: effectivelyExpanded ? 0.25 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: effectivelyExpanded
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                        child: Text(
                          reasoning,
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: cs.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController input;
  final bool isStreaming;
  final VoidCallback onSend;
  final VoidCallback onStop;
  const _Composer({
    required this.input,
    required this.isStreaming,
    required this.onSend,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.sm),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: input,
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: loc.chatComposerHint,
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (_) => isStreaming ? null : onSend(),
              ),
            ),
            const SizedBox(width: Spacing.sm),
            isStreaming
                ? IconButton.filled(
                    icon: const Icon(Icons.stop),
                    onPressed: onStop,
                    tooltip: loc.chatStopTooltip,
                  )
                : IconButton.filled(
                    icon: const Icon(Icons.send),
                    onPressed: onSend,
                    tooltip: loc.chatSendTooltip,
                  ),
          ],
        ),
      ),
    );
  }
}

class _NoServer extends StatelessWidget {
  final String? error;
  const _NoServer({this.error});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return EmptyState(
      icon: Icons.cloud_off,
      title: error == null
          ? loc.chatNoActiveServerTitle
          : loc.chatCannotConnectTitle,
      body: error ?? loc.chatNoActiveServerHint,
    );
  }
}

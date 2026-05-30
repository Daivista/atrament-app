import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import '../../../core/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/code_block.dart';
import '../../../shared/widgets/empty_state.dart';
import 'chat_controller.dart';
import 'chat_parameters_sheet.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final appColors = Theme.of(context).extension<AppColors>()!;
    final targetAsync = ref.watch(chatTargetProvider);
    final chat = ref.watch(chatControllerProvider);

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
          // Sesja A2: settings icon otwiera ChatParametersSheet z dropdownem
          // modelu + 3 trybami parametrów + system prompt.
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
                child: _MessageList(scroll: _scroll, chat: chat),
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
  const _MessageList({required this.scroll, required this.chat});

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
          return _Bubble(
            text: m.content,
            isUser: m.role == 'user',
            isPartial: m.isPartial,
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
  const _Bubble({
    required this.text,
    required this.isUser,
    this.reasoning = '',
    this.streaming = false,
    this.isPartial = false,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final body = text + (streaming ? ' ▋' : '');
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
              if (reasoning.isNotEmpty) ...[
                Text(
                  '🧠 ${loc.chatReasoningLabel}',
                  style: TextStyle(fontSize: 11, color: cs.outline),
                ),
                Text(
                  reasoning,
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const Divider(height: 12),
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

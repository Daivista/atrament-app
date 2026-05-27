import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profiles/presentation/profiles_screen.dart';
import 'chat_controller.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final text = _input.text;
    if (text.trim().isEmpty) return;
    _input.clear();
    ref.read(chatControllerProvider.notifier).send(text);
  }

  @override
  Widget build(BuildContext context) {
    final targetAsync = ref.watch(chatTargetProvider);
    final chat = ref.watch(chatControllerProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: targetAsync.maybeWhen(
          data: (t) =>
              Text(t == null ? 'Atrament' : 'Atrament — ${t.profileName}'),
          orElse: () => const Text('Atrament'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: 'Nowa rozmowa',
            onPressed: chat.isStreaming
                ? null
                : () => ref.read(chatControllerProvider.notifier).newChat(),
          ),
          IconButton(
            icon: const Icon(Icons.dns),
            tooltip: 'Serwery',
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProfilesScreen())),
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
              if (chat.error != null)
                Container(
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.errorContainer,
                  padding: const EdgeInsets.all(8),
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
    final showStreaming =
        chat.isStreaming ||
        chat.streamingContent.isNotEmpty ||
        chat.streamingReasoning.isNotEmpty;
    final itemCount = chat.messages.length + (showStreaming ? 1 : 0);

    if (itemCount == 0) {
      return const Center(child: Text('Napisz wiadomość, by zacząć rozmowę.'));
    }

    return ListView.builder(
      controller: scroll,
      padding: const EdgeInsets.all(12),
      itemCount: itemCount,
      itemBuilder: (context, i) {
        if (i < chat.messages.length) {
          final m = chat.messages[i];
          return _Bubble(text: m.content, isUser: m.role == 'user');
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
  const _Bubble({
    required this.text,
    required this.isUser,
    this.reasoning = '',
    this.streaming = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
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
                '🧠 Myślenie',
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
            Text(text + (streaming ? ' ▋' : '')),
          ],
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: input,
                minLines: 1,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Napisz wiadomość…',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => isStreaming ? null : onSend(),
              ),
            ),
            const SizedBox(width: 8),
            isStreaming
                ? IconButton.filled(
                    icon: const Icon(Icons.stop),
                    onPressed: onStop,
                    tooltip: 'Zatrzymaj',
                  )
                : IconButton.filled(
                    icon: const Icon(Icons.send),
                    onPressed: onSend,
                    tooltip: 'Wyślij',
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
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 64, color: cs.outline),
            const SizedBox(height: 16),
            Text(
              error == null ? 'Brak aktywnego serwera' : 'Nie można połączyć',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error ??
                  'Ustaw aktywny serwer (gwiazdka) w zarządzaniu serwerami, '
                      'by zacząć rozmowę.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.dns),
              label: const Text('Zarządzaj serwerami'),
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ProfilesScreen())),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/database.dart';
import '../../../core/providers/providers.dart';
import 'chat_repository.dart';
import 'message_repository.dart';

part 'chat_providers.g.dart';

@Riverpod(keepAlive: true)
ChatRepository chatRepository(Ref ref) => ChatRepository();

@Riverpod(keepAlive: true)
MessageRepository messageRepository(Ref ref) {
  return MessageRepository(ref.watch(databaseProvider));
}

// Reaktywna lista czatów — ręczny StreamProvider (jak profilesListProvider),
// bo riverpod_generator 4.x-dev pada na Stream<List<...>> z typami Drift.
final chatsListProvider = StreamProvider<List<Chat>>((ref) {
  return ref.watch(messageRepositoryProvider).watchChats();
});

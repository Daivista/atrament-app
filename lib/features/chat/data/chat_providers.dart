import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'chat_repository.dart';

part 'chat_providers.g.dart';

// ChatRepository to zwykły typ → @riverpod generuje bez problemu
// (w przeciwieństwie do Stream<List<T>> które robiliśmy ręcznie).
@Riverpod(keepAlive: true)
ChatRepository chatRepository(Ref ref) => ChatRepository();

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/database.dart';
import '../../../core/providers/providers.dart';
import 'profile_repository.dart';

part 'profile_providers.g.dart';

// profileRepository zostaje generowany (@riverpod działa dla zwykłych typów).
@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepository(
    ref.watch(databaseProvider),
    ref.watch(secureKeyStoreProvider),
  );
}

// profilesList: ręczny StreamProvider zamiast @riverpod.
// Powód: riverpod_generator 4.x-dev rzuca InvalidTypeException przy
// Stream<List<Profile>> (typ generowany przez Drift). Ręczny provider
// omija generator dla tego typu. Mieszanie obu stylów jest wspierane.
// TODO: wrócić do @riverpod gdy wyjdzie stabilny riverpod_generator.
final profilesListProvider = StreamProvider<List<Profile>>((ref) {
  return ref.watch(profileRepositoryProvider).watchProfiles();
});

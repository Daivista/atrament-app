import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/database.dart';
import '../../../core/providers/providers.dart';
import 'profile_repository.dart';

part 'profile_providers.g.dart';

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepository(
    ref.watch(databaseProvider),
    ref.watch(secureKeyStoreProvider),
  );
}

// Ręczny StreamProvider — riverpod_generator 4.x-dev rzuca InvalidTypeException
// przy Stream<...> z typami Drift. (TODO: @riverpod gdy stabilny generator)
final profilesListProvider = StreamProvider<List<Profile>>((ref) {
  return ref.watch(profileRepositoryProvider).watchProfiles();
});

// Aktywny profil — ten sam powód dla ręcznego stylu (Stream<String?>).
final activeProfileIdProvider = StreamProvider<String?>((ref) {
  return ref.watch(profileRepositoryProvider).watchActiveProfileId();
});

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/database.dart';
import '../../../core/storage/secure_key_store.dart';

class ProfileRepository {
  final AppDatabase _db;
  final SecureKeyStore _keyStore;

  ProfileRepository(this._db, this._keyStore);

  /// Zapisuje nowy profil: rekord do Drift + klucz do secure storage.
  /// Zwraca id utworzonego profilu.
  Future<String> saveProfile({
    required String name,
    required String baseUrl,
    required String type,
    String? apiKey,
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    final hasKey = apiKey != null && apiKey.isNotEmpty;

    if (hasKey) {
      await _keyStore.setApiKey(id, apiKey);
    }

    await _db
        .into(_db.profiles)
        .insert(
          ProfilesCompanion.insert(
            id: id,
            name: name,
            type: type,
            baseUrl: baseUrl,
            createdAt: now,
            apiKeyRef: Value(hasKey ? 'profile_$id' : null),
          ),
        );
    return id;
  }

  /// Odczytuje klucz API dla profilu, z recovery.
  /// INVARIANT (manifest 11): jeśli profil ma apiKeyRef (kiedyś zapisano klucz),
  /// ale secure storage zwraca null → Keystore zgubił klucz (np. backup/restore).
  /// secure_storage 10.x resetuje przy błędzie zamiast rzucać, więc wykrywamy
  /// utratę przez rozbieżność stanu, nie przez wyjątek → ustawiamy flagę.
  Future<String?> getApiKey(String profileId) async {
    final profile = await (_db.select(
      _db.profiles,
    )..where((p) => p.id.equals(profileId))).getSingleOrNull();
    if (profile == null) return null;

    final key = await _keyStore.getApiKey(profileId);

    if (profile.apiKeyRef != null && key == null) {
      await (_db.update(_db.profiles)..where((p) => p.id.equals(profileId)))
          .write(const ProfilesCompanion(apiKeyNeedsReentry: Value(true)));
      return null;
    }
    return key;
  }

  /// Reaktywny strumień profili (do listy w UI).
  Stream<List<Profile>> watchProfiles() {
    return (_db.select(
      _db.profiles,
    )..orderBy([(p) => OrderingTerm(expression: p.createdAt)])).watch();
  }

  Future<List<Profile>> getAllProfiles() {
    return (_db.select(
      _db.profiles,
    )..orderBy([(p) => OrderingTerm(expression: p.createdAt)])).get();
  }

  /// Usuwa profil: najpierw klucz z secure storage, potem rekord z bazy
  /// (kolejność wg manifestu — by nie zostać z kluczem-sierotą gdyby coś padło).
  Future<void> deleteProfile(String profileId) async {
    await _keyStore.deleteApiKey(profileId);
    await (_db.delete(_db.profiles)..where((p) => p.id.equals(profileId))).go();
  }
}

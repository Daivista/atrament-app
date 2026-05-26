import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/database.dart';
import '../../../core/storage/secure_key_store.dart';

class ProfileRepository {
  final AppDatabase _db;
  final SecureKeyStore _keyStore;

  ProfileRepository(this._db, this._keyStore);

  static const _kActiveProfile = 'app.active_profile_id';

  Future<String> saveProfile({
    required String name,
    required String baseUrl,
    required String type,
    String? apiKey,
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    final hasKey = apiKey != null && apiKey.isNotEmpty;
    if (hasKey) await _keyStore.setApiKey(id, apiKey);
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

  Future<void> updateProfile({
    required String id,
    required String name,
    required String baseUrl,
    String? newApiKey,
    bool clearApiKey = false,
  }) async {
    final current = await (_db.select(
      _db.profiles,
    )..where((p) => p.id.equals(id))).getSingleOrNull();
    if (current == null) return;

    String? apiKeyRef = current.apiKeyRef;
    if (clearApiKey) {
      await _keyStore.deleteApiKey(id);
      apiKeyRef = null;
    } else if (newApiKey != null && newApiKey.isNotEmpty) {
      await _keyStore.setApiKey(id, newApiKey);
      apiKeyRef = 'profile_$id';
    }

    await (_db.update(_db.profiles)..where((p) => p.id.equals(id))).write(
      ProfilesCompanion(
        name: Value(name),
        baseUrl: Value(baseUrl),
        apiKeyRef: Value(apiKeyRef),
        apiKeyNeedsReentry: const Value(false),
      ),
    );
  }

  /// INVARIANT (manifest 11): rozbieżność apiKeyRef↔null = klucz utracony.
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

  Future<void> deleteProfile(String profileId) async {
    await _keyStore.deleteApiKey(profileId);
    await (_db.delete(_db.profiles)..where((p) => p.id.equals(profileId))).go();
    final active = await _getActiveId();
    if (active == profileId) {
      await clearActiveProfile();
    }
  }

  // ── Aktywny profil (user_variables, klucz systemowy app.*) ──

  Future<void> setActiveProfileId(String id) {
    return _db
        .into(_db.userVariables)
        .insertOnConflictUpdate(
          UserVariablesCompanion.insert(key: _kActiveProfile, value: Value(id)),
        );
  }

  /// Usuwa oznaczenie aktywnego profilu (żaden nie jest aktywny).
  Future<void> clearActiveProfile() {
    return (_db.delete(
      _db.userVariables,
    )..where((v) => v.key.equals(_kActiveProfile))).go();
  }

  Stream<String?> watchActiveProfileId() {
    return (_db.select(_db.userVariables)
          ..where((v) => v.key.equals(_kActiveProfile)))
        .watchSingleOrNull()
        .map((row) => row?.value);
  }

  Future<String?> _getActiveId() async {
    final row = await (_db.select(
      _db.userVariables,
    )..where((v) => v.key.equals(_kActiveProfile))).getSingleOrNull();
    return row?.value;
  }
}

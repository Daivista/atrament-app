import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Przechowuje klucze API. Konwencja klucza: "profile_${profileId}" (manifest 9, 11).
/// W 10.x przy nieodwracalnym błędzie Keystore plugin sam resetuje dane
/// (resetOnError=true domyślnie), więc getApiKey zwraca null zamiast rzucać.
/// Detekcja "klucz utracony vs nigdy nie było" dzieje się w repository
/// przez porównanie z profiles.apiKeyRef (manifest 11 — graceful recovery).
class SecureKeyStore {
  final FlutterSecureStorage _storage;

  SecureKeyStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  String _keyName(String profileId) => 'profile_$profileId';

  Future<void> setApiKey(String profileId, String apiKey) =>
      _storage.write(key: _keyName(profileId), value: apiKey);

  Future<String?> getApiKey(String profileId) =>
      _storage.read(key: _keyName(profileId));

  Future<void> deleteApiKey(String profileId) =>
      _storage.delete(key: _keyName(profileId));
}

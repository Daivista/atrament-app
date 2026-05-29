import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/database.dart';
import '../storage/secure_key_store.dart';
import '../network/api_client.dart';

part 'providers.g.dart';

// keepAlive: baza żyje przez całe życie aplikacji.
@Riverpod(keepAlive: true)
AppDatabase database(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

@Riverpod(keepAlive: true)
SecureKeyStore secureKeyStore(Ref ref) => SecureKeyStore();

@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) => ApiClient();

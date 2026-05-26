import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/database.dart';

part 'providers.g.dart';

// keepAlive: baza żyje przez całe życie aplikacji (nie tworzymy jej na nowo).
@Riverpod(keepAlive: true)
AppDatabase database(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

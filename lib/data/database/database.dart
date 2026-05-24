import 'package:drift/drift.dart';
import 'connection.dart';

part 'database.g.dart';

class Profiles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get baseUrl => text()();
  TextColumn get apiKeyRef => text().nullable()();
  BoolColumn get apiKeyNeedsReentry =>
      boolean().withDefault(const Constant(false))();
  TextColumn get serverVersion => text().nullable()();
  TextColumn get featureFlagsJson => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get lastUsedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Profiles])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? openConnection());

  @override
  int get schemaVersion => 1;
}

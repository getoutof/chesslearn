import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'database.g.dart';

/// Сохранённые партии. Партия хранится в PGN; остальные поля — чтобы
/// показывать список, не разбирая PGN каждой партии.
class SavedGames extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get pgn => text()();

  /// Заголовки PGN (JSON): у импортированных партий — имена игроков,
  /// турнир и т.п. При пересохранении партии они не теряются.
  TextColumn get headers => text().map(const _HeadersConverter())();

  /// На каком ходу стоит доска — чтобы продолжить с того же места.
  IntColumn get ply => integer()();
  IntColumn get moveCount => integer()();

  /// Результат как в PGN: `1-0`, `0-1`, `1/2-1/2` или `*` — не закончена.
  TextColumn get result => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

class _HeadersConverter extends TypeConverter<Map<String, String>, String> {
  const _HeadersConverter();

  @override
  Map<String, String> fromSql(String fromDb) =>
      (jsonDecode(fromDb) as Map<String, Object?>).cast<String, String>();

  @override
  String toSql(Map<String, String> value) => jsonEncode(value);
}

@DriftDatabase(tables: [SavedGames])
class AppDatabase extends _$AppDatabase {
  /// [executor] — для тестов (база в памяти); по умолчанию — файл
  /// `chesslearn.sqlite` в папке приложения.
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'chesslearn'));

  @override
  int get schemaVersion => 1;
}

/// База приложения. Открывается при первом запросе.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

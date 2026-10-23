import 'package:dartchess/dartchess.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database.dart';
import '../game/game.dart';
import '../game/game_pgn.dart';

/// Сохранённые партии: запись, чтение, список.
class SavedGamesRepository {
  SavedGamesRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  /// Сохраняет новую партию и возвращает её id. [headers] — заголовки PGN,
  /// например у импортированной партии; `Date` по умолчанию — сегодня.
  Future<int> create(Game game, {PgnHeaders headers = const {}}) {
    final now = _clock();
    final allHeaders = {'Date': _pgnDate(now), ...headers};
    return _db
        .into(_db.savedGames)
        .insert(
          SavedGamesCompanion.insert(
            pgn: gameToPgn(game, headers: allHeaders),
            headers: allHeaders,
            ply: game.ply,
            moveCount: game.moves.length,
            result: _result(game),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  /// Перезаписывает партию [id], сохраняя её заголовки.
  Future<void> update(int id, Game game) async {
    final row = await (_db.select(
      _db.savedGames,
    )..where((t) => t.id.equals(id))).getSingle();
    await (_db.update(_db.savedGames)..where((t) => t.id.equals(id))).write(
      SavedGamesCompanion(
        pgn: Value(gameToPgn(game, headers: row.headers)),
        ply: Value(game.ply),
        moveCount: Value(game.moves.length),
        result: Value(_result(game)),
        updatedAt: Value(_clock()),
      ),
    );
  }

  /// Партия [id] на том ходу, на котором её оставили.
  Future<Game> load(int id) async {
    final row = await (_db.select(
      _db.savedGames,
    )..where((t) => t.id.equals(id))).getSingle();
    return _toGame(row);
  }

  /// Последняя по времени изменения незаконченная партия.
  Future<({int id, Game game})?> lastUnfinished() async {
    final row =
        await (_db.select(_db.savedGames)
              ..where((t) => t.result.equals('*'))
              ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : (id: row.id, game: _toGame(row));
  }

  /// Все партии, последние изменённые — первыми.
  Stream<List<SavedGame>> watchAll() => (_db.select(
    _db.savedGames,
  )..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).watch();

  Future<void> delete(int id) =>
      (_db.delete(_db.savedGames)..where((t) => t.id.equals(id))).go();

  static Game _toGame(SavedGame row) {
    final game = gameFromPgn(row.pgn).game;
    return game.goTo(row.ply.clamp(0, game.moves.length));
  }

  static String _result(Game game) =>
      Outcome.toPgnString(game.goTo(game.moves.length).outcome);

  static String _pgnDate(DateTime date) =>
      '${date.year}.${_two(date.month)}.${_two(date.day)}';

  static String _two(int n) => n.toString().padLeft(2, '0');
}

final savedGamesRepositoryProvider = Provider<SavedGamesRepository>(
  (ref) => SavedGamesRepository(ref.watch(databaseProvider)),
);

import 'package:chesslearn/src/core/database.dart';
import 'package:chesslearn/src/features/game/game.dart';
import 'package:chesslearn/src/features/saved_games/saved_games_repository.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_container.dart';

Game _play(Game game, List<String> uci) =>
    uci.fold(game, (g, m) => g.play(Move.parse(m)!));

void main() {
  late AppDatabase db;
  late SavedGamesRepository repository;
  late DateTime now;

  setUp(() {
    db = createTestDatabase();
    now = DateTime(2026, 10, 23, 12);
    repository = SavedGamesRepository(db, clock: () => now);
  });

  test('сохранённая партия загружается на том же ходу', () async {
    final game = _play(const Game(), ['e2e4', 'e7e5', 'g1f3']).undo();
    final id = await repository.create(game);

    final loaded = await repository.load(id);
    expect([for (final m in loaded.moves) m.san], ['e4', 'e5', 'Nf3']);
    expect(loaded.ply, 2);
    expect(loaded.fen, game.fen);
  });

  test('поля для списка и дата в PGN', () async {
    final mate = _play(const Game(), ['f2f3', 'e7e5', 'g2g4', 'd8h4']);
    final id = await repository.create(mate);

    final row = (await repository.watchAll().first).single;
    expect(row.id, id);
    expect(row.moveCount, 4);
    expect(row.result, '0-1');
    expect(row.createdAt, now);
    expect(row.pgn, contains('[Date "2026.10.23"]'));
  });

  test('update перезаписывает партию и сохраняет заголовки', () async {
    final id = await repository.create(
      _play(const Game(), ['e2e4']),
      headers: {'White': 'Morphy'},
    );
    now = now.add(const Duration(minutes: 5));
    await repository.update(id, _play(const Game(), ['e2e4', 'e7e5']));

    final row = (await repository.watchAll().first).single;
    expect(row.moveCount, 2);
    expect(row.updatedAt, now);
    expect(row.pgn, contains('[White "Morphy"]'));
    expect(row.pgn, contains('1. e4 e5'));
  });

  test('lastUnfinished — последняя изменённая незаконченная', () async {
    expect(await repository.lastUnfinished(), isNull);

    final older = await repository.create(_play(const Game(), ['e2e4']));
    now = now.add(const Duration(minutes: 1));
    final newer = await repository.create(_play(const Game(), ['d2d4']));
    now = now.add(const Duration(minutes: 1));
    await repository.create(
      _play(const Game(), ['f2f3', 'e7e5', 'g2g4', 'd8h4']),
    );

    expect((await repository.lastUnfinished())?.id, newer);

    now = now.add(const Duration(minutes: 1));
    await repository.update(older, _play(const Game(), ['e2e4', 'e7e5']));
    final last = await repository.lastUnfinished();
    expect(last?.id, older);
    expect(last?.game.moves, hasLength(2));
  });

  test('сдавшаяся партия — законченная, итог сохраняется', () async {
    final id = await repository.create(
      _play(const Game(), ['e2e4']).resign(Side.black),
    );

    expect(await repository.lastUnfinished(), isNull);
    expect((await repository.watchAll().first).single.result, '1-0');
    expect(
      (await repository.load(id)).result,
      const GameResult(Outcome.whiteWins, GameEnd.resignation),
    );
  });

  test('список — последние изменённые первыми; удаление', () async {
    final first = await repository.create(_play(const Game(), ['e2e4']));
    now = now.add(const Duration(minutes: 1));
    final second = await repository.create(_play(const Game(), ['d2d4']));

    expect(
      [for (final r in await repository.watchAll().first) r.id],
      [second, first],
    );

    await repository.delete(second);
    expect([for (final r in await repository.watchAll().first) r.id], [first]);
  });
}

import 'package:chesslearn/src/features/game/game.dart';
import 'package:chesslearn/src/core/database.dart';
import 'package:chesslearn/src/features/game/game_controller.dart';
import 'package:chesslearn/src/features/saved_games/saved_games_repository.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_container.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = createTestContainer();
    // Запись в базу асинхронная — дождаться её до закрытия контейнера
    // (addTearDown выполняются в обратном порядке).
    addTearDown(() => container.read(gameProvider.notifier).saved);
  });

  GameController controller() => container.read(gameProvider.notifier);

  test('начинается с начальной позиции', () {
    expect(container.read(gameProvider).fen, kInitialFEN);
  });

  test('play меняет текущую партию', () {
    controller().play(Move.parse('e2e4')!);
    expect(container.read(gameProvider).moves.single.san, 'e4');
  });

  test('undo, redo и goTo двигают текущий ход', () {
    controller()
      ..play(Move.parse('e2e4')!)
      ..play(Move.parse('e7e5')!)
      ..undo();
    expect(container.read(gameProvider).ply, 1);
    controller().redo();
    expect(container.read(gameProvider).ply, 2);
    controller().goTo(0);
    expect(container.read(gameProvider).fen, kInitialFEN);
  });

  test('start начинает новую партию', () {
    controller()
      ..play(Move.parse('e2e4')!)
      ..start();
    expect(container.read(gameProvider).moves, isEmpty);

    const fen = '4k3/8/8/8/8/8/8/R3K3 w Q - 0 1';
    controller().start(Game.fromFen(fen));
    expect(container.read(gameProvider).fen, fen);
  });

  group('автосохранение', () {
    SavedGamesRepository repository() =>
        container.read(savedGamesRepositoryProvider);

    Future<List<SavedGame>> saved() async {
      await controller().saved;
      return repository().watchAll().first;
    }

    test('пустая партия не сохраняется', () async {
      controller().start();
      expect(await saved(), isEmpty);
    });

    test('первый ход создаёт запись, следующие её обновляют', () async {
      controller()
        ..play(Move.parse('e2e4')!)
        ..play(Move.parse('e7e5')!)
        ..undo();
      final rows = await saved();
      expect(rows, hasLength(1));
      expect(rows.single.moveCount, 2);
      expect(rows.single.ply, 1);
    });

    test('новая партия — новая запись', () async {
      controller()
        ..play(Move.parse('e2e4')!)
        ..start()
        ..play(Move.parse('d2d4')!);
      expect(await saved(), hasLength(2));
    });

    test('restore продолжает последнюю незаконченную партию', () async {
      controller()
        ..play(Move.parse('e2e4')!)
        ..play(Move.parse('e7e5')!)
        ..undo();
      await controller().saved;

      // Новый запуск приложения: та же база, новый контроллер.
      final restarted = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(container.read(databaseProvider)),
        ],
      );
      addTearDown(restarted.dispose);
      await restarted.read(gameProvider.notifier).restore();

      final game = restarted.read(gameProvider);
      expect(game.moves, hasLength(2));
      expect(game.ply, 1);

      // И продолжает писать в ту же запись.
      restarted.read(gameProvider.notifier).play(Move.parse('c7c5')!);
      await restarted.read(gameProvider.notifier).saved;
      final rows = await repository().watchAll().first;
      expect(rows.single.pgn, contains('1. e4 c5'));
    });

    test('без сохранённых партий restore ничего не меняет', () async {
      await controller().restore();
      expect(container.read(gameProvider).fen, kInitialFEN);
    });
  });

  group('сохранённые партии', () {
    test('импорт PGN — новая сохранённая партия с заголовками', () async {
      await controller().importPgn('[White "Morphy"]\n\n1. e4 e5 *');
      expect(container.read(gameProvider).moves, hasLength(2));

      controller().play(Move.parse('g1f3')!);
      final pgn = await controller().pgn();
      expect(pgn, contains('[White "Morphy"]'));
      expect(pgn, contains('1. e4 e5 2. Nf3 *'));
    });

    test('PGN несохранённой партии', () async {
      expect(await controller().pgn(), contains('[Result "*"]'));
    });

    test('удаление текущей партии начинает новую', () async {
      controller().play(Move.parse('e2e4')!);
      await controller().saved;
      final id =
          (await container.read(savedGamesRepositoryProvider).watchAll().first)
              .single
              .id;

      await controller().deleteSaved(id);
      expect(container.read(gameProvider).moves, isEmpty);

      controller().play(Move.parse('d2d4')!);
      await controller().saved;
      final rows = await container
          .read(savedGamesRepositoryProvider)
          .watchAll()
          .first;
      expect(rows.single.pgn, contains('1. d4'));
    });

    test('openSaved открывает партию на сохранённом ходу', () async {
      controller()
        ..play(Move.parse('e2e4')!)
        ..play(Move.parse('e7e5')!)
        ..undo();
      await controller().saved;
      final id =
          (await container.read(savedGamesRepositoryProvider).watchAll().first)
              .single
              .id;
      controller().start();

      await controller().openSaved(id);
      expect(container.read(gameProvider).ply, 1);
      expect(container.read(gameProvider).moves, hasLength(2));
    });
  });
}

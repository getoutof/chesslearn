import 'package:chesslearn/src/features/game/game.dart';
import 'package:chesslearn/src/features/game/game_controller.dart';
import 'package:chesslearn/src/features/hotseat/hotseat_screen.dart';
import 'package:chesslearn/src/features/saved_games/saved_games_repository.dart';
import 'package:chesslearn/src/features/saved_games/saved_games_screen.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_container.dart';

Game _play(Game game, List<String> uci) =>
    uci.fold(game, (g, m) => g.play(Move.parse(m)!));

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  List<Game> games = const [],
}) async {
  final container = createTestContainer();
  for (final game in games) {
    await tester.runAsync(
      () => container.read(savedGamesRepositoryProvider).create(game),
    );
  }
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: SavedGamesScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('пустой список', (tester) async {
    await _pump(tester);
    expect(find.text('Сохранённых партий пока нет'), findsOneWidget);
  });

  testWidgets('партия в списке открывается на доске', (tester) async {
    final container = await _pump(
      tester,
      games: [
        _play(const Game(), ['e2e4', 'e7e5', 'g1f3']),
      ],
    );
    expect(find.textContaining('Не закончена · 2 хода'), findsOneWidget);

    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();

    expect(find.byType(HotseatScreen), findsOneWidget);
    expect(container.read(gameProvider).moves, hasLength(3));
  });

  testWidgets('импорт PGN — партия сохранена и открыта', (tester) async {
    final container = await _pump(tester);

    await tester.tap(find.byTooltip('Импорт PGN'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField),
      '[White "Morphy"]\n[Black "Isouard"]\n\n1. e4 e5 2. Nf3 d6 *',
    );
    await tester.tap(find.text('Открыть'));
    await tester.pumpAndSettle();

    expect(find.byType(HotseatScreen), findsOneWidget);
    expect(container.read(gameProvider).moves, hasLength(4));

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Morphy — Isouard'), findsOneWidget);
  });

  testWidgets('нечитаемый PGN — сообщение', (tester) async {
    await _pump(tester);

    await tester.tap(find.byTooltip('Импорт PGN'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '1. e4 e5 2. Ke3');
    await tester.tap(find.text('Открыть'));
    await tester.pumpAndSettle();

    expect(find.text('Не удалось прочитать PGN'), findsOneWidget);
    expect(find.byType(HotseatScreen), findsNothing);
  });

  testWidgets('удаление — после подтверждения', (tester) async {
    await _pump(
      tester,
      games: [
        _play(const Game(), ['e2e4']),
      ],
    );

    await tester.drag(find.byType(ListTile), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsOneWidget);

    await tester.drag(find.byType(ListTile), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Удалить'));
    await tester.pumpAndSettle();
    expect(find.text('Сохранённых партий пока нет'), findsOneWidget);
  });

  group('тексты', () {
    test('число ходов', () {
      expect(movesText(0), '0 ходов');
      expect(movesText(1), '1 ход');
      expect(movesText(4), '2 хода');
      expect(movesText(9), '5 ходов');
      expect(movesText(22), '11 ходов');
      expect(movesText(24), '12 ходов');
      expect(movesText(41), '21 ход');
      expect(movesText(44), '22 хода');
    });

    test('результат и дата', () {
      expect(resultText('1-0'), 'Победили белые');
      expect(resultText('0-1'), 'Победили чёрные');
      expect(resultText('1/2-1/2'), 'Ничья');
      expect(resultText('*'), 'Не закончена');
      expect(formatDateTime(DateTime(2026, 3, 5, 9, 7)), '05.03.2026, 09:07');
    });
  });
}

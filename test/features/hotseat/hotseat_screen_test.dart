import 'package:chesslearn/src/features/game/game.dart';
import 'package:chesslearn/src/features/game/game_controller.dart';
import 'package:chesslearn/src/features/hotseat/hotseat_screen.dart';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ProviderContainer> _pump(WidgetTester tester) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: HotseatScreen()),
    ),
  );
  return container;
}

Future<void> _tapSquare(WidgetTester tester, String name) async {
  final square = Square.fromName(name);
  final board = tester.getRect(find.byType(Chessboard));
  final cell = board.width / 8;
  await tester.tapAt(
    board.topLeft +
        Offset((square.file + 0.5) * cell, (7 - square.rank + 0.5) * cell),
  );
  await tester.pumpAndSettle();
}

Chessboard _board(WidgetTester tester) =>
    tester.widget<Chessboard>(find.byType(Chessboard));

void main() {
  testWidgets('ход на доске попадает в партию', (tester) async {
    final container = await _pump(tester);

    await _tapSquare(tester, 'e2');
    await _tapSquare(tester, 'e4');

    expect(container.read(gameProvider).moves.single.san, 'e4');
    expect(_board(tester).controller.lastMove, Move.parse('e2e4'));
  });

  testWidgets('после мата доска не принимает ходы', (tester) async {
    final container = await _pump(tester);
    container
        .read(gameProvider.notifier)
        .start(
          Game.fromFen(
            'rnb1kbnr/pppp1ppp/8/4p3/6Pq/5P2/PPPPP2P/RNBQKBNR w KQkq - 1 3',
          ),
        );
    await tester.pumpAndSettle();

    expect(container.read(gameProvider).isCheckmate, isTrue);
    expect(_board(tester).controller.interactive, isFalse);
  });

  testWidgets('некорректный FEN — сообщение, партия не меняется', (
    tester,
  ) async {
    final container = await _pump(tester);

    await tester.tap(find.byTooltip('Позиция из FEN'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'not a fen');
    await tester.tap(find.text('Показать'));
    await tester.pumpAndSettle();

    expect(find.text('Некорректный FEN'), findsOneWidget);
    expect(container.read(gameProvider).fen, kInitialFEN);
  });
}

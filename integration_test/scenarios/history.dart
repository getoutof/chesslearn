import 'package:chesslearn/src/features/hotseat/hotseat_screen.dart';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app.dart';

/// E2E: переворот доски и отмена хода (#45).
void historyScenarios() {
  group('переворот доски и отмена хода', () {
    Future<void> start(WidgetTester tester) async {
      await launchApp(tester);
      await openFromMenu(tester, HotseatScreen.title);
    }

    Future<void> tapButton(WidgetTester tester, String tooltip) async {
      await tester.tap(find.byTooltip(tooltip));
      await tester.pumpAndSettle();
    }

    IconButton button(WidgetTester tester, String tooltip) =>
        tester.widget<IconButton>(
          find.ancestor(
            of: find.byTooltip(tooltip),
            matching: find.byType(IconButton),
          ),
        );

    testWidgets('перевёрнутая доска: чёрные внизу, ходы работают', (
      tester,
    ) async {
      await start(tester);
      await tapButton(tester, 'Перевернуть доску');
      expect(board(tester).orientation, Side.black);
      // Белая пешка e2 — вверху доски.
      final rect = tester.getRect(find.byType(Chessboard));
      expect(squareCenter(tester, 'e2').dy, lessThan(rect.center.dy));

      await playMoves(tester, ['e2e4']);
      await dragPiece(tester, 'e7', 'e5');
      expect(sanMoves(), ['e4', 'e5']);
      await screenshot(tester, '45-01-flipped');

      await tapButton(tester, 'Перевернуть доску');
      expect(board(tester).orientation, Side.white);
    });

    testWidgets('отмена хода — позиция, последний ход и очередь', (
      tester,
    ) async {
      await start(tester);
      expect(button(tester, 'Отменить ход').onPressed, isNull);

      await playMoves(tester, ['e2e4', 'e7e5']);
      await tapButton(tester, 'Отменить ход');

      expect(currentGame().ply, 1);
      expect(board(tester).controller.lastMove, Move.parse('e2e4'));
      expect(find.text('Ход чёрных'), findsOneWidget);
      await screenshot(tester, '45-02-undo');

      await tapButton(tester, 'Отменить ход');
      expect(currentGame().fen, kInitialFEN);
      expect(board(tester).controller.lastMove, isNull);
      expect(button(tester, 'Отменить ход').onPressed, isNull);

      await tapButton(tester, 'К последнему ходу');
      expect(currentGame().ply, 2);
    });

    testWidgets('отмена после мата — доска снова принимает ходы', (
      tester,
    ) async {
      await start(tester);
      await playMoves(tester, ['f2f3', 'e7e5', 'g2g4', 'd8h4']);
      await tester.tap(find.text('К позиции'));
      await tester.pumpAndSettle();
      expect(board(tester).controller.interactive, isFalse);

      await tapButton(tester, 'Отменить ход');
      expect(board(tester).controller.interactive, isTrue);
      expect(find.text('Ход чёрных'), findsOneWidget);

      await playMoves(tester, ['b8c6']);
      expect(sanMoves(), ['f3', 'e5', 'g4', 'Nc6']);
    });
  });
}

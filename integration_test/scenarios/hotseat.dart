import 'package:chesslearn/src/features/hotseat/hotseat_screen.dart';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app.dart';

/// E2E: партия вдвоём на одном телефоне (#44).
void hotseatScenarios() {
  group('игра вдвоём', () {
    Future<void> start(WidgetTester tester) async {
      await launchApp(tester);
      await openFromMenu(tester, HotseatScreen.title);
    }

    Finder inDialog(String text) => find.descendant(
      of: find.byType(AlertDialog),
      matching: find.text(text),
    );

    testWidgets('ход касаниями и перетаскиванием', (tester) async {
      await start(tester);
      await playMoves(tester, ['e2e4']);
      await dragPiece(tester, 'e7', 'e5');

      expect(sanMoves(), ['e4', 'e5']);
      expect(board(tester).controller.lastMove, Move.parse('e7e5'));
      await screenshot(tester, '44-01-moves');
    });

    testWidgets('нелегальный ход не проходит', (tester) async {
      await start(tester);
      await playMoves(tester, ['e2e5']);
      await dragPiece(tester, 'g1', 'g3');

      expect(currentGame().fen, kInitialFEN);
      expect(find.text('Ход белых'), findsOneWidget);
    });

    testWidgets('взятие на проходе и рокировка', (tester) async {
      await start(tester);
      await playMoves(tester, [
        'e2e4', 'a7a6', 'e4e5', 'd7d5', 'e5d6', //
        'a6a5', 'g1f3', 'a5a4', 'f1c4', 'a4a3', 'e1g1',
      ]);

      expect(sanMoves(), containsAllInOrder(['exd6', 'O-O']));
      await screenshot(tester, '44-02-castling');
    });

    testWidgets('превращение пешки — выбор фигуры', (tester) async {
      await start(tester);
      await _loadFen(tester, '8/P6k/8/8/8/8/8/K7 w - - 0 1');
      await playMoves(tester, ['a7a8']);
      await screenshot(tester, '44-03-promotion');

      await tester.tap(
        find.byWidgetPredicate(
          (w) =>
              w is PieceWidget &&
              w.piece.promoted &&
              w.piece.role == Role.knight,
        ),
      );
      await tester.pumpAndSettle();
      expect(sanMoves(), ['a8=N']);
      expect(currentGame().position.board.roleAt(Square.a8), Role.knight);
    });

    testWidgets('детский мат — итог, доска не принимает ходы', (tester) async {
      await start(tester);
      await playMoves(tester, [
        'e2e4', 'e7e5', 'f1c4', 'b8c6', 'd1h5', 'g8f6', 'h5f7', //
      ]);

      expect(inDialog('Победили белые'), findsOneWidget);
      expect(inDialog('Мат'), findsOneWidget);
      await screenshot(tester, '44-04-mate');

      await tester.tap(find.text('К позиции'));
      await tester.pumpAndSettle();
      expect(find.text('Победили белые. Мат'), findsOneWidget);
      expect(board(tester).controller.interactive, isFalse);
    });

    testWidgets('позиция из FEN: ошибка, затем пат', (tester) async {
      await start(tester);
      await _loadFen(tester, 'not a fen');
      expect(find.text('Некорректный FEN'), findsOneWidget);
      expect(currentGame().fen, kInitialFEN);

      await _loadFen(tester, '7k/8/6Q1/8/8/8/8/K7 w - - 0 1');
      await playMoves(tester, ['g6f7']);
      expect(inDialog('Ничья'), findsOneWidget);
      expect(inDialog('Пат'), findsOneWidget);
      await screenshot(tester, '44-05-stalemate');
    });

    testWidgets('ничья троекратным повторением', (tester) async {
      await start(tester);
      const shuffle = ['g1f3', 'g8f6', 'f3g1', 'f6g8'];
      await playMoves(tester, [...shuffle, ...shuffle]);

      expect(inDialog('Ничья'), findsOneWidget);
      expect(inDialog('Троекратное повторение позиции'), findsOneWidget);
    });

    testWidgets('выход в меню и возврат — партия продолжается', (tester) async {
      await start(tester);
      await playMoves(tester, ['e2e4', 'e7e5']);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(HotseatScreen), findsNothing);

      await openFromMenu(tester, HotseatScreen.title);
      expect(sanMoves(), ['e4', 'e5']);
      expect(board(tester).controller.lastMove, Move.parse('e7e5'));
      expect(find.text('Ход белых'), findsOneWidget);
    });
  });
}

/// Вводит FEN в окне «Позиция из FEN».
Future<void> _loadFen(WidgetTester tester, String fen) async {
  await tester.tap(find.byTooltip('Позиция из FEN'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), fen);
  await tester.tap(find.text('Показать'));
  await tester.pumpAndSettle();
}

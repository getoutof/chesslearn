import 'package:chesslearn/src/features/board/board_view.dart';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _boardSize = 400.0;

Widget _wrap(Widget child) => MaterialApp(
  home: Center(
    child: SizedBox.square(dimension: _boardSize, child: child),
  ),
);

/// Центр клетки на доске, повёрнутой белыми вниз.
Offset _center(WidgetTester tester, String square) {
  final s = Square.fromName(square);
  const cell = _boardSize / 8;
  final topLeft = tester.getTopLeft(find.byType(Chessboard));
  return topLeft + Offset((s.file + 0.5) * cell, (7 - s.rank + 0.5) * cell);
}

Future<void> _tapSquare(WidgetTester tester, String square) async {
  await tester.tapAt(_center(tester, square));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('рисует позицию из FEN', (tester) async {
    const fen = '4k3/8/8/8/8/8/4P3/4K3 w - - 0 1';
    await tester.pumpWidget(
      _wrap(BoardView(position: Chess.fromSetup(Setup.parseFen(fen)))),
    );

    final board = tester.widget<Chessboard>(find.byType(Chessboard));
    expect(board.controller.fen, fen);
    expect(board.controller.pieces, hasLength(3));
  });

  testWidgets('ход двумя касаниями приходит в onMove', (tester) async {
    final moves = <Move>[];
    await tester.pumpWidget(
      _wrap(BoardView(position: Chess.initial, onMove: moves.add)),
    );

    await _tapSquare(tester, 'e2');
    await _tapSquare(tester, 'e4');

    expect(moves, [const NormalMove(from: Square.e2, to: Square.e4)]);
  });

  testWidgets('ход перетаскиванием приходит в onMove', (tester) async {
    final moves = <Move>[];
    await tester.pumpWidget(
      _wrap(BoardView(position: Chess.initial, onMove: moves.add)),
    );

    final gesture = await tester.startGesture(_center(tester, 'g1'));
    await gesture.moveTo(_center(tester, 'g1') + const Offset(10, -10));
    await gesture.moveTo(_center(tester, 'f3'));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(moves, [const NormalMove(from: Square.g1, to: Square.f3)]);
  });

  testWidgets('при превращении пешки доска предлагает выбрать фигуру', (
    tester,
  ) async {
    final moves = <Move>[];
    final position = Chess.fromSetup(
      Setup.parseFen('4k3/P7/8/8/8/8/8/4K3 w - - 0 1'),
    );
    await tester.pumpWidget(
      _wrap(BoardView(position: position, onMove: moves.add)),
    );

    await _tapSquare(tester, 'a7');
    await _tapSquare(tester, 'a8');
    expect(moves, isEmpty, reason: 'ход ждёт выбора фигуры');

    // Выбор фигуры показан столбцом от a8 вниз: ферзь, конь, ладья, слон.
    await _tapSquare(tester, 'a7');
    expect(moves, [
      const NormalMove(from: Square.a7, to: Square.a8, promotion: Role.knight),
    ]);
  });

  testWidgets('нелегальный ход не проходит', (tester) async {
    final moves = <Move>[];
    await tester.pumpWidget(
      _wrap(BoardView(position: Chess.initial, onMove: moves.add)),
    );

    await _tapSquare(tester, 'e2');
    await _tapSquare(tester, 'e5');

    expect(moves, isEmpty);
  });

  testWidgets('подсвечивает короля под шахом и последний ход', (tester) async {
    final move = const NormalMove(from: Square.d8, to: Square.h4);
    // Позиция после хода чёрных Фd8-h4: белому королю шах.
    final checked = Chess.fromSetup(
      Setup.parseFen(
        'rnbqkbnr/pppp1ppp/8/4p3/6P1/5P2/PPPPP2P/RNBQKBNR b KQkq - 0 2',
      ),
    ).play(move);

    await tester.pumpWidget(
      _wrap(BoardView(position: checked, lastMove: move)),
    );

    final game = tester
        .widget<Chessboard>(find.byType(Chessboard))
        .controller
        .game;
    expect(game.kingSquareInCheck, Square.e1);
    expect(game.lastMove, move);
  });

  testWidgets('новая позиция в виджете обновляет доску', (tester) async {
    await tester.pumpWidget(_wrap(const BoardView(position: Chess.initial)));
    final after = Chess.initial.play(
      const NormalMove(from: Square.e2, to: Square.e4),
    );
    await tester.pumpWidget(_wrap(BoardView(position: after)));
    await tester.pumpAndSettle();

    final board = tester.widget<Chessboard>(find.byType(Chessboard));
    expect(board.controller.fen, after.fen);
  });
}

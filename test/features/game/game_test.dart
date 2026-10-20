import 'package:chesslearn/src/features/game/game.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter_test/flutter_test.dart';

/// Играет ходы в UCI-записи: `e2e4`, `e7e8q`.
Game _play(Game game, List<String> uci) =>
    uci.fold(game, (g, m) => g.play(Move.parse(m)!));

void main() {
  test('новая партия — начальная позиция, ход белых', () {
    const game = Game();
    expect(game.fen, kInitialFEN);
    expect(game.turn, Side.white);
    expect(game.moves, isEmpty);
    expect(game.lastMove, isNull);
    expect(game.outcome, isNull);
  });

  test('ход возвращает новую партию, старая не меняется', () {
    const game = Game();
    final next = game.play(Move.parse('e2e4')!);

    expect(game.moves, isEmpty);
    expect(next.moves.single.san, 'e4');
    expect(next.turn, Side.black);
    expect(next.lastMove, Move.parse('e2e4'));
    expect(
      next.fen,
      'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
    );
  });

  test('список ходов в SAN', () {
    final game = _play(const Game(), ['e2e4', 'e7e5', 'g1f3', 'b8c6']);
    expect([for (final m in game.moves) m.san], ['e4', 'e5', 'Nf3', 'Nc6']);
  });

  test('нелегальный ход бросает PlayException', () {
    expect(
      () => const Game().play(Move.parse('e2e5')!),
      throwsA(isA<PlayException>()),
    );
    expect(const Game().isLegal(Move.parse('e2e5')!), isFalse);
  });

  group('рокировка', () {
    const fen = 'r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1';

    for (final uci in ['e1g1', 'e1h1']) {
      test('короткая ходом $uci', () {
        final game = Game.fromFen(fen).play(Move.parse(uci)!);
        expect(game.moves.single.san, 'O-O');
        expect(game.position.board.pieceAt(Square.g1)?.role, Role.king);
        expect(game.position.board.pieceAt(Square.f1)?.role, Role.rook);
        expect(game.lastMove, Move.parse('e1h1'));
      });
    }

    test('длинная', () {
      final game = Game.fromFen(fen).play(Move.parse('e1c1')!);
      expect(game.moves.single.san, 'O-O-O');
      expect(game.position.board.pieceAt(Square.c1)?.role, Role.king);
      expect(game.position.board.pieceAt(Square.d1)?.role, Role.rook);
    });

    test('нельзя рокироваться через битое поле', () {
      final game = Game.fromFen('4k3/8/8/8/8/8/5r2/R3K2R w KQ - 0 1');
      expect(game.isLegal(Move.parse('e1g1')!), isFalse);
      expect(game.isLegal(Move.parse('e1c1')!), isTrue);
    });
  });

  test('взятие на проходе', () {
    final game = _play(const Game(), ['e2e4', 'a7a6', 'e4e5', 'd7d5', 'e5d6']);
    expect(game.moves.last.san, 'exd6');
    expect(game.position.board.pieceAt(Square.d5), isNull);
    expect(game.position.board.pieceAt(Square.d6)?.role, Role.pawn);
  });

  test('взятие на проходе возможно только сразу', () {
    final game = _play(const Game(), [
      'e2e4', 'a7a6', 'e4e5', 'd7d5', 'h2h3', 'h7h6', //
    ]);
    expect(game.isLegal(Move.parse('e5d6')!), isFalse);
  });

  group('превращение пешки', () {
    const fen = '4k3/P7/8/8/8/8/8/4K3 w - - 0 1';

    test('в ферзя', () {
      final game = Game.fromFen(fen).play(Move.parse('a7a8q')!);
      expect(game.moves.single.san, 'a8=Q+');
      expect(game.position.board.pieceAt(Square.a8)?.role, Role.queen);
    });

    test('в коня', () {
      final game = Game.fromFen(fen).play(Move.parse('a7a8n')!);
      expect(game.moves.single.san, 'a8=N');
      expect(game.position.board.pieceAt(Square.a8)?.role, Role.knight);
    });

    test('без выбора фигуры ход нелегален', () {
      expect(Game.fromFen(fen).isLegal(Move.parse('a7a8')!), isFalse);
      expect(
        () => Game.fromFen(fen).play(Move.parse('a7a8')!),
        throwsA(isA<PlayException>()),
      );
    });
  });

  test('шах', () {
    final game = _play(const Game(), ['e2e4', 'f7f6', 'd1h5']);
    expect(game.moves.last.san, 'Qh5+');
    expect(game.isCheck, isTrue);
    expect(game.outcome, isNull);
  });

  test('мат: детский мат белым', () {
    final game = _play(const Game(), ['f2f3', 'e7e5', 'g2g4', 'd8h4']);
    expect(game.moves.last.san, 'Qh4#');
    expect(game.isCheckmate, isTrue);
    expect(game.outcome, Outcome.blackWins);
  });

  test('пат', () {
    final game = Game.fromFen('7k/8/6Q1/8/8/8/8/K7 w - - 0 1')
        .play(Move.parse('g6f7')!);
    expect(game.isStalemate, isTrue);
    expect(game.isCheck, isFalse);
    expect(game.outcome, Outcome.draw);
  });

  test('недостаток материала — ничья', () {
    final game = Game.fromFen('4k3/8/8/8/8/8/3r4/4K3 w - - 0 1')
        .play(Move.parse('e1d2')!);
    expect(game.outcome, Outcome.draw);
  });

  test('некорректный FEN', () {
    expect(() => Game.fromFen('not a fen'), throwsA(isA<FenException>()));
    expect(
      () => Game.fromFen('8/8/8/8/8/8/8/8 w - - 0 1'),
      throwsA(isA<PositionSetupException>()),
    );
  });
}

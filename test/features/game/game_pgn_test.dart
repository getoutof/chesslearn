import 'package:chesslearn/src/features/game/game.dart';
import 'package:chesslearn/src/features/game/game_pgn.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter_test/flutter_test.dart';

Game _play(Game game, List<String> uci) =>
    uci.fold(game, (g, m) => g.play(Move.parse(m)!));

void main() {
  group('запись в PGN', () {
    test('ходы, заголовки и результат', () {
      final game = _play(const Game(), ['f2f3', 'e7e5', 'g2g4', 'd8h4']);
      final pgn = gameToPgn(
        game,
        headers: {'White': 'Анна', 'Black': 'Борис', 'Date': '2026.10.23'},
      );
      expect(pgn, contains('[White "Анна"]'));
      expect(pgn, contains('[Date "2026.10.23"]'));
      expect(pgn, contains('[Result "0-1"]'));
      expect(pgn, contains('1. f3 e5 2. g4 Qh4# 0-1'));
      expect(pgn, isNot(contains('FEN')));
    });

    test('незаконченная партия — результат «*»', () {
      final pgn = gameToPgn(_play(const Game(), ['e2e4']));
      expect(pgn, contains('[Result "*"]'));
      expect(pgn, contains('1. e4 *'));
    });

    test('отменённые ходы тоже записываются', () {
      final game = _play(const Game(), ['e2e4', 'e7e5']).undo();
      expect(gameToPgn(game), contains('1. e4 e5 *'));
    });

    test('партия из FEN — SetUp и FEN', () {
      const fen = '4k3/8/8/8/8/8/8/4K2R b K - 0 12';
      final pgn = gameToPgn(_play(Game.fromFen(fen), ['e8d7']));
      expect(pgn, contains('[SetUp "1"]'));
      expect(pgn, contains('[FEN "$fen"]'));
      expect(pgn, contains('12... Kd7 *'));
    });
  });

  group('чтение из PGN', () {
    test('туда и обратно — та же партия', () {
      const fen = '4k3/8/8/8/8/8/8/4K2R b K - 0 12';
      final game = _play(Game.fromFen(fen), ['e8d7', 'e1g1', 'd7e6']);
      final read = gameFromPgn(gameToPgn(game)).game;

      expect(read.start.fen, fen);
      expect([for (final m in read.moves) m.san], ['Kd7', 'O-O', 'Ke6']);
      expect(read.ply, 3);
      expect(read.fen, game.fen);
    });

    test('заголовки, комментарии и варианты', () {
      final (:game, :headers) = gameFromPgn('''
[Event "Casual"]
[White "Morphy"]
[Black "Duke Karl / Count Isouard"]

1. e4 {King's pawn} e5 (1... c5 2. Nf3) 2. Nf3 d6 *
''');
      expect(headers['White'], 'Morphy');
      expect([for (final m in game.moves) m.san], ['e4', 'e5', 'Nf3', 'd6']);
    });

    test('пустой PGN — новая партия', () {
      expect(gameFromPgn('').game.moves, isEmpty);
    });

    test('нелегальный ход — FormatException', () {
      expect(
        () => gameFromPgn('1. e4 e5 2. Ke3 *'),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('Ke3'),
          ),
        ),
      );
    });

    test('некорректный FEN — FormatException', () {
      expect(
        () => gameFromPgn('[SetUp "1"]\n[FEN "not a fen"]\n\n*'),
        throwsFormatException,
      );
    });

    test('другой вариант шахмат — FormatException', () {
      expect(
        () => gameFromPgn('[Variant "Atomic"]\n\n1. e4 *'),
        throwsFormatException,
      );
    });
  });
}

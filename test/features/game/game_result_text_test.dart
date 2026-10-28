import 'package:chesslearn/src/features/game/game.dart';
import 'package:chesslearn/src/features/game/game_result_text.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('победитель', () {
    expect(
      const GameResult(Outcome.whiteWins, GameEnd.checkmate).title,
      'Победили белые',
    );
    expect(
      const GameResult(Outcome.blackWins, GameEnd.checkmate).title,
      'Победили чёрные',
    );
    expect(const GameResult(Outcome.draw, GameEnd.stalemate).title, 'Ничья');
  });

  test('кто сдался', () {
    expect(
      const GameResult(Outcome.blackWins, GameEnd.resignation).reason,
      'Белые сдались',
    );
    expect(
      const GameResult(Outcome.whiteWins, GameEnd.resignation).reason,
      'Чёрные сдались',
    );
  });

  test('у каждой причины есть текст', () {
    for (final end in GameEnd.values) {
      expect(GameResult(Outcome.draw, end).reason, isNotEmpty);
    }
  });
}

import 'package:chesslearn/src/features/hotseat/board_orientation.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('без автоповорота — белые внизу, переворот меняет сторону', () {
    for (final turn in Side.values) {
      expect(
        boardOrientation(turn: turn, autoRotate: false, flipped: false),
        Side.white,
      );
      expect(
        boardOrientation(turn: turn, autoRotate: false, flipped: true),
        Side.black,
      );
    }
  });

  test('автоповорот — внизу сторона, которая ходит', () {
    for (final turn in Side.values) {
      expect(
        boardOrientation(turn: turn, autoRotate: true, flipped: false),
        turn,
      );
      expect(
        boardOrientation(turn: turn, autoRotate: true, flipped: true),
        turn.opposite,
      );
    }
  });
}

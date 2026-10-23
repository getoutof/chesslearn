import 'package:chesslearn/src/features/game/game.dart';
import 'package:chesslearn/src/features/game/game_controller.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

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
}

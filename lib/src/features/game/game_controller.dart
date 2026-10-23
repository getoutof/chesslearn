import 'package:dartchess/dartchess.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'game.dart';

/// Текущая партия.
final gameProvider = NotifierProvider<GameController, Game>(GameController.new);

class GameController extends Notifier<Game> {
  @override
  Game build() => const Game();

  void play(Move move) => state = state.play(move);

  void undo() => state = state.undo();
  void redo() => state = state.redo();
  void goTo(int ply) => state = state.goTo(ply);

  /// Начинает новую партию: с начальной позиции или с [game].
  void start([Game? game]) => state = game ?? const Game();
}

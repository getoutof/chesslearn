import 'package:dartchess/dartchess.dart';

import 'game.dart';

/// Тексты итога партии для экранов.
extension GameResultText on GameResult {
  /// Кто победил: «Победили белые» или «Ничья».
  String get title => switch (outcome.winner) {
    Side.white => 'Победили белые',
    Side.black => 'Победили чёрные',
    null => 'Ничья',
  };

  /// Почему партия закончилась.
  String get reason => switch (end) {
    GameEnd.checkmate => 'Мат',
    GameEnd.stalemate => 'Пат',
    GameEnd.insufficientMaterial => 'Недостаточно материала для мата',
    GameEnd.threefoldRepetition => 'Троекратное повторение позиции',
    GameEnd.fiftyMoves => 'Правило 50 ходов',
    GameEnd.resignation => switch (outcome.winner) {
      Side.white => 'Чёрные сдались',
      Side.black => 'Белые сдались',
      null => 'Сдача',
    },
    GameEnd.agreement => 'По соглашению сторон',
  };
}

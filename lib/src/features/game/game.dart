import 'package:dartchess/dartchess.dart';
import 'package:flutter/foundation.dart';

/// Сделанный ход: сам ход, его запись в SAN и позиция после него.
@immutable
class GameMove {
  const GameMove({
    required this.move,
    required this.san,
    required this.position,
  });

  final Move move;
  final String san;
  final Position position;
}

/// Партия: стартовая позиция и сделанные ходы. Неизменяема — [play]
/// возвращает новую партию.
///
/// Все правила — из dartchess: легальность ходов, рокировка, взятие на
/// проходе, превращение пешки, шах, мат и пат.
@immutable
class Game {
  const Game({Position? start}) : this._(start ?? Chess.initial, const []);

  /// Партия с позиции из FEN. Бросает [FenException] или
  /// [PositionSetupException], если FEN некорректен.
  factory Game.fromFen(String fen) =>
      Game(start: Chess.fromSetup(Setup.parseFen(fen)));

  const Game._(this.start, this.moves);

  final Position start;
  final List<GameMove> moves;

  Position get position => moves.isEmpty ? start : moves.last.position;
  String get fen => position.fen;
  Side get turn => position.turn;
  Move? get lastMove => moves.isEmpty ? null : moves.last.move;

  bool get isCheck => position.isCheck;
  bool get isCheckmate => position.isCheckmate;
  bool get isStalemate => position.isStalemate;

  /// Итог по позиции: мат, пат или недостаток материала; `null`, если
  /// партия продолжается. Троекратное повторение и правило 50 ходов — в #5.
  Outcome? get outcome => position.outcome;

  /// dartchess считает легальным ход пешки на последнюю горизонталь без
  /// выбора фигуры и оставляет там пешку, поэтому такой ход отсекаем сами.
  bool isLegal(Move move) =>
      position.isLegal(move) && !_isPromotionWithoutRole(move);

  bool _isPromotionWithoutRole(Move move) =>
      move is NormalMove &&
      move.promotion == null &&
      position.board.pawns.has(move.from) &&
      SquareSet.backranks.has(move.to);

  /// Делает ход. Рокировку можно передать и ходом короля на две клетки
  /// (e1-g1), и ходом короля на ладью (e1-h1): в партии она хранится во
  /// втором виде, как в dartchess. Бросает [PlayException], если ход
  /// нелегален.
  Game play(Move move) {
    if (_isPromotionWithoutRole(move)) {
      throw PlayException('Promotion role is required: $move');
    }
    final normalized = move is NormalMove ? position.normalizeMove(move) : move;
    final (next, san) = position.makeSan(normalized);
    return Game._(
      start,
      List.unmodifiable([
        ...moves,
        GameMove(move: normalized, san: san, position: next),
      ]),
    );
  }
}

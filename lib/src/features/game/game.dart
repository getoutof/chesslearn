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

/// Почему партия закончилась.
enum GameEnd {
  checkmate,
  stalemate,
  insufficientMaterial,
  threefoldRepetition,
  fiftyMoves,
}

/// Итог партии: кто победил (или ничья) и почему.
@immutable
class GameResult {
  const GameResult(this.outcome, this.end);

  final Outcome outcome;
  final GameEnd end;

  @override
  bool operator ==(Object other) =>
      other is GameResult && other.outcome == outcome && other.end == end;

  @override
  int get hashCode => Object.hash(outcome, end);

  @override
  String toString() => 'GameResult($outcome, ${end.name})';
}

/// Партия: стартовая позиция, сделанные ходы и текущий ход [ply], на
/// котором стоит доска. Неизменяема — [play], [undo], [redo] и [goTo]
/// возвращают новую партию.
///
/// [undo] и [redo] только передвигают [ply], ходы при этом сохраняются.
/// Ход из прошлой позиции отбрасывает всё, что было после неё.
///
/// Все правила — из dartchess: легальность ходов, рокировка, взятие на
/// проходе, превращение пешки, шах, мат и пат.
@immutable
class Game {
  const Game({Position? start}) : this._(start ?? Chess.initial, const [], 0);

  /// Партия с позиции из FEN. Бросает [FenException] или
  /// [PositionSetupException], если FEN некорректен.
  factory Game.fromFen(String fen) =>
      Game(start: Chess.fromSetup(Setup.parseFen(fen)));

  const Game._(this.start, this.moves, this.ply);

  final Position start;

  /// Все ходы партии, в том числе отменённые, которые можно вернуть [redo].
  final List<GameMove> moves;

  /// Сколько ходов из [moves] сделано на доске: 0 — стартовая позиция.
  final int ply;

  Position get position => ply == 0 ? start : moves[ply - 1].position;
  String get fen => position.fen;
  Side get turn => position.turn;
  Move? get lastMove => ply == 0 ? null : moves[ply - 1].move;

  bool get canUndo => ply > 0;
  bool get canRedo => ply < moves.length;

  /// Переходит к позиции после хода [ply]: 0 — стартовая позиция.
  Game goTo(int ply) {
    RangeError.checkValueInInterval(ply, 0, moves.length, 'ply');
    return Game._(start, moves, ply);
  }

  Game undo() => goTo(ply - 1);
  Game redo() => goTo(ply + 1);

  bool get isCheck => position.isCheck;
  bool get isCheckmate => position.isCheckmate;
  bool get isStalemate => position.isStalemate;

  /// Итог партии; `null`, если партия продолжается.
  ///
  /// Мат, пат и недостаток материала считает dartchess. Троекратное
  /// повторение и правило 50 ходов по правилам FIDE — право потребовать
  /// ничью, но у нас, как в большинстве приложений, ничья наступает сама.
  GameResult? get result {
    final position = this.position;
    if (position.isCheckmate) {
      return GameResult(
        Outcome(winner: position.turn.opposite),
        GameEnd.checkmate,
      );
    }
    if (position.isStalemate) {
      return const GameResult(Outcome.draw, GameEnd.stalemate);
    }
    if (position.isInsufficientMaterial) {
      return const GameResult(Outcome.draw, GameEnd.insufficientMaterial);
    }
    if (_repetitions >= 3) {
      return const GameResult(Outcome.draw, GameEnd.threefoldRepetition);
    }
    if (position.halfmoves >= 100) {
      return const GameResult(Outcome.draw, GameEnd.fiftyMoves);
    }
    return null;
  }

  Outcome? get outcome => result?.outcome;

  /// Сколько раз до текущего хода встретилась текущая позиция, включая её
  /// саму.
  ///
  /// Позиции совпадают, если совпадают расстановка, очередь хода, права на
  /// рокировку и возможность взятия на проходе — это первые четыре поля
  /// FEN (dartchess пишет поле взятия на проходе, только если оно возможно).
  int get _repetitions {
    final current = _repetitionKey(position);
    return [
      start,
      for (final m in moves.take(ply)) m.position,
    ].where((p) => _repetitionKey(p) == current).length;
  }

  static String _repetitionKey(Position position) =>
      position.fen.split(' ').take(4).join(' ');

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
        ...moves.take(ply),
        GameMove(move: normalized, san: san, position: next),
      ]),
      ply + 1,
    );
  }
}

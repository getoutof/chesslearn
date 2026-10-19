import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/widgets.dart';

/// Интерактивная доска: показывает [position] и сообщает о ходах через
/// [onMove].
///
/// Доска позволяет делать только легальные ходы (их считает dartchess),
/// подсвечивает [lastMove], возможные ходы выбранной фигуры и короля под
/// шахом. Ходы — перетаскиванием или двумя касаниями; превращение пешки
/// предлагает выбрать фигуру. Сам ход не применяется: позицию меняет
/// владелец виджета.
class BoardView extends StatefulWidget {
  const BoardView({
    super.key,
    required this.position,
    this.lastMove,
    this.orientation = Side.white,
    this.playerSide = PlayerSide.both,
    this.onMove,
  });

  final Position position;
  final Move? lastMove;

  /// Чьи фигуры внизу.
  final Side orientation;

  /// Кто может двигать фигуры: обе стороны (игра вдвоём), одна или никто.
  final PlayerSide playerSide;

  final void Function(Move move)? onMove;

  @override
  State<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> {
  late final _controller = ChessboardController(game: _game());

  GameData _game() {
    final position = widget.position;
    return GameData(
      fen: position.fen,
      lastMove: widget.lastMove,
      playerSide: widget.playerSide,
      sideToMove: position.turn,
      validMoves: makeLegalMoves(position),
      kingSquareInCheck: position.isCheck
          ? position.board.kingOf(position.turn)
          : null,
    );
  }

  @override
  void didUpdateWidget(BoardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.position != oldWidget.position ||
        widget.lastMove != oldWidget.lastMove ||
        widget.playerSide != oldWidget.playerSide) {
      _controller.updatePosition(_game());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Chessboard(
        size: constraints.biggest.shortestSide,
        controller: _controller,
        orientation: widget.orientation,
        onMove: (move, {viaDragAndDrop}) => widget.onMove?.call(move),
      ),
    );
  }
}

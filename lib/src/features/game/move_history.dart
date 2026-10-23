import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';

import 'game.dart';

/// Ходы партии в строку: «1. e4 e5 2. Nf3». Текущий ход выделен и всегда
/// виден; нажатие на ход переводит доску к позиции после него.
class MoveList extends StatefulWidget {
  const MoveList({super.key, required this.game, required this.onGoTo});

  final Game game;

  /// Переход к позиции после хода с номером ply (1 — первый ход).
  final ValueChanged<int> onGoTo;

  @override
  State<MoveList> createState() => _MoveListState();
}

class _MoveListState extends State<MoveList> {
  final _current = GlobalKey();

  @override
  void didUpdateWidget(MoveList oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _current.currentContext;
      if (context != null && context.mounted) {
        Scrollable.ensureVisible(context, alignment: 0.5);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final theme = Theme.of(context);
    // Номер хода в записи учитывает стартовую позицию: партия из FEN может
    // начинаться с 12-го хода и с хода чёрных («12… Kd7»).
    final blackFirst = game.start.turn == Side.black;
    String? number(int index) {
      final white = (index + (blackFirst ? 1 : 0)).isEven;
      final n = game.start.fullmoves + (index + (blackFirst ? 1 : 0)) ~/ 2;
      if (white) return '$n.';
      if (index == 0) return '$n…';
      return null;
    }

    return SizedBox(
      height: 40,
      child: game.moves.isEmpty
          ? Center(
              child: Text('Ходов пока нет', style: theme.textTheme.bodySmall),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  for (final (index, move) in game.moves.indexed) ...[
                    if (number(index) case final n?)
                      Padding(
                        padding: const EdgeInsets.only(left: 8, right: 2),
                        child: Text(n, style: theme.textTheme.bodySmall),
                      ),
                    ChoiceChip(
                      key: index + 1 == game.ply ? _current : null,
                      label: Text(move.san),
                      selected: index + 1 == game.ply,
                      showCheckmark: false,
                      visualDensity: VisualDensity.compact,
                      onSelected: (_) => widget.onGoTo(index + 1),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

/// Кнопки истории: в начало, отменить ход, вернуть ход, к последнему ходу.
class HistoryButtons extends StatelessWidget {
  const HistoryButtons({super.key, required this.game, required this.onGoTo});

  final Game game;
  final ValueChanged<int> onGoTo;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: 'В начало',
          icon: const Icon(Icons.first_page),
          onPressed: game.canUndo ? () => onGoTo(0) : null,
        ),
        IconButton(
          tooltip: 'Отменить ход',
          icon: const Icon(Icons.undo),
          onPressed: game.canUndo ? () => onGoTo(game.ply - 1) : null,
        ),
        IconButton(
          tooltip: 'Вернуть ход',
          icon: const Icon(Icons.redo),
          onPressed: game.canRedo ? () => onGoTo(game.ply + 1) : null,
        ),
        IconButton(
          tooltip: 'К последнему ходу',
          icon: const Icon(Icons.last_page),
          onPressed: game.canRedo ? () => onGoTo(game.moves.length) : null,
        ),
      ],
    );
  }
}

import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart' show Move, Side, kInitialFEN;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../board/board_view.dart';
import '../game/game.dart';
import '../game/game_controller.dart';
import '../game/game_result_text.dart';
import '../game/move_history.dart';
import 'board_orientation.dart';

/// Игра вдвоём на одном телефоне: обе стороны ходят по очереди.
///
/// Над доской — чей ход или итог партии, под доской — ходы и кнопки
/// отмены. Когда ход на доске заканчивает партию, показывается окно
/// результата. Партия живёт в [gameProvider], поэтому после возврата в меню
/// её можно продолжить.
class HotseatScreen extends ConsumerWidget {
  const HotseatScreen({super.key});

  static const title = 'Игра вдвоём';

  Future<void> _loadFen(BuildContext context, WidgetRef ref) async {
    final fen = await showDialog<String>(
      context: context,
      builder: (context) => const _FenDialog(),
    );
    if (fen == null || !context.mounted) return;
    try {
      ref.read(gameProvider.notifier).start(Game.fromFen(fen.trim()));
    } on Exception {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Некорректный FEN')));
    }
  }

  /// Делает ход и, если он закончил партию, показывает окно результата.
  /// Окно — только после хода: при переходах по истории к концу партии
  /// итог виден над доской.
  Future<void> _play(BuildContext context, WidgetRef ref, Move move) async {
    final controller = ref.read(gameProvider.notifier)..play(move);
    final result = ref.read(gameProvider).result;
    if (result == null) return;
    final action = await showDialog<_ResultAction>(
      context: context,
      builder: (context) => _ResultDialog(result),
    );
    if (!context.mounted) return;
    switch (action) {
      case _ResultAction.newGame:
        controller.start();
      case _ResultAction.menu:
        Navigator.of(context).popUntil((route) => route.isFirst);
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final controller = ref.read(gameProvider.notifier);
    final autoRotate = ref.watch(autoRotateProvider);
    final flipped = ref.watch(boardFlippedProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(title),
        actions: [
          IconButton(
            tooltip: 'Перевернуть доску',
            icon: const Icon(Icons.swap_vert),
            onPressed: ref.read(boardFlippedProvider.notifier).toggle,
          ),
          IconButton(
            tooltip: 'Позиция из FEN',
            icon: const Icon(Icons.edit_note),
            onPressed: () => _loadFen(context, ref),
          ),
          IconButton(
            tooltip: 'Начальная позиция',
            icon: const Icon(Icons.restart_alt),
            onPressed: () => ref.read(gameProvider.notifier).start(),
          ),
          PopupMenuButton<void>(
            itemBuilder: (context) => [
              CheckedPopupMenuItem(
                checked: autoRotate,
                onTap: ref.read(autoRotateProvider.notifier).toggle,
                child: const Text('Поворачивать доску после хода'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: _GameStatus(game),
            ),
            // Доска — квадрат по меньшей из сторон оставшегося места.
            Flexible(
              child: AspectRatio(
                aspectRatio: 1,
                child: BoardView(
                  position: game.position,
                  lastMove: game.lastMove,
                  orientation: boardOrientation(
                    turn: game.turn,
                    autoRotate: autoRotate,
                    flipped: flipped,
                  ),
                  playerSide: game.outcome == null
                      ? PlayerSide.both
                      : PlayerSide.none,
                  onMove: (move) => _play(context, ref, move),
                ),
              ),
            ),
            const SizedBox(height: 8),
            MoveList(game: game, onGoTo: controller.goTo),
            HistoryButtons(game: game, onGoTo: controller.goTo),
          ],
        ),
      ),
    );
  }
}

/// Строка над доской: чей ход (и шах) или итог партии.
class _GameStatus extends StatelessWidget {
  const _GameStatus(this.game);

  final Game game;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleMedium;
    final result = game.result;
    if (result != null) {
      return Text('${result.title}. ${result.reason}', style: style);
    }
    final side = game.turn == Side.white ? 'белых' : 'чёрных';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SideMark(game.turn),
        const SizedBox(width: 8),
        Text(game.isCheck ? 'Ход $side — шах!' : 'Ход $side', style: style),
      ],
    );
  }
}

/// Кружок цвета стороны, которая ходит.
class _SideMark extends StatelessWidget {
  const _SideMark(this.side);

  final Side side;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: side == Side.white ? Colors.white : Colors.black,
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
    );
  }
}

enum _ResultAction { newGame, menu }

/// Окно результата: итог партии и что делать дальше. Закрыть окно —
/// остаться смотреть финальную позицию.
class _ResultDialog extends StatelessWidget {
  const _ResultDialog(this.result);

  final GameResult result;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(result.title),
      content: Text(result.reason),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('К позиции'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _ResultAction.menu),
          child: const Text('В меню'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _ResultAction.newGame),
          child: const Text('Новая партия'),
        ),
      ],
    );
  }
}

class _FenDialog extends StatefulWidget {
  const _FenDialog();

  @override
  State<_FenDialog> createState() => _FenDialogState();
}

class _FenDialogState extends State<_FenDialog> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Позиция из FEN'),
      content: TextField(
        controller: _text,
        autofocus: true,
        decoration: const InputDecoration(hintText: kInitialFEN),
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _text.text),
          child: const Text('Показать'),
        ),
      ],
    );
  }
}

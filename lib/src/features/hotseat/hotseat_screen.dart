import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart' show kInitialFEN;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../board/board_view.dart';
import '../game/game.dart';
import '../game/game_controller.dart';

/// Игра вдвоём на одном телефоне: обе стороны ходят по очереди.
///
/// Партия живёт в [gameProvider], поэтому после возврата в меню её можно
/// продолжить. Остальное для hot-seat — в #5.
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(title),
        actions: [
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
        ],
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: BoardView(
            position: game.position,
            lastMove: game.lastMove,
            playerSide: game.outcome == null
                ? PlayerSide.both
                : PlayerSide.none,
            onMove: ref.read(gameProvider.notifier).play,
          ),
        ),
      ),
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

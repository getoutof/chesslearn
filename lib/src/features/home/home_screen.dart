import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';

import '../../app.dart';
import '../board/board_view.dart';

/// Временный главный экран: свободная игра на доске, чтобы её можно было
/// попробовать. Настоящее меню и навигация — в #4, модель партии — в #3.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position _position = Chess.initial;
  Move? _lastMove;

  void _setPosition(Position position) => setState(() {
    _position = position;
    _lastMove = null;
  });

  Future<void> _loadFen() async {
    final fen = await showDialog<String>(
      context: context,
      builder: (context) => const _FenDialog(),
    );
    if (fen == null || !mounted) return;
    try {
      _setPosition(Chess.fromSetup(Setup.parseFen(fen.trim())));
    } on Exception {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Некорректный FEN')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ChessLearnApp.title),
        actions: [
          IconButton(
            tooltip: 'Позиция из FEN',
            icon: const Icon(Icons.edit_note),
            onPressed: _loadFen,
          ),
          IconButton(
            tooltip: 'Начальная позиция',
            icon: const Icon(Icons.restart_alt),
            onPressed: () => _setPosition(Chess.initial),
          ),
        ],
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: BoardView(
            position: _position,
            lastMove: _lastMove,
            onMove: (move) => setState(() {
              _position = _position.play(move);
              _lastMove = move;
            }),
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

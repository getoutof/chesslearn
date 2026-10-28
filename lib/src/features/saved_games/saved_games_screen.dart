import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database.dart';
import '../game/game_controller.dart';
import '../hotseat/hotseat_screen.dart';
import 'saved_games_repository.dart';

final savedGamesProvider = StreamProvider<List<SavedGame>>(
  (ref) => ref.watch(savedGamesRepositoryProvider).watchAll(),
);

/// Сохранённые партии: открыть (и продолжить), удалить, импортировать PGN.
class SavedGamesScreen extends ConsumerWidget {
  const SavedGamesScreen({super.key});

  static const title = 'Сохранённые партии';

  Future<void> _open(BuildContext context, WidgetRef ref, int id) async {
    await ref.read(gameProvider.notifier).openSaved(id);
    if (!context.mounted) return;
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const HotseatScreen()));
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final pgn = await showDialog<String>(
      context: context,
      builder: (context) => const _PgnDialog(),
    );
    if (pgn == null || !context.mounted) return;
    try {
      await ref.read(gameProvider.notifier).importPgn(pgn);
    } on FormatException {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Не удалось прочитать PGN')));
      return;
    }
    if (!context.mounted) return;
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const HotseatScreen()));
  }

  Future<bool> _confirmDelete(BuildContext context) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Удалить партию?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Удалить'),
            ),
          ],
        ),
      ) ??
      false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final games = ref.watch(savedGamesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(title),
        actions: [
          IconButton(
            tooltip: 'Импорт PGN',
            icon: const Icon(Icons.content_paste),
            onPressed: () => _import(context, ref),
          ),
        ],
      ),
      body: switch (games) {
        AsyncData(value: []) => const Center(
          child: Text('Сохранённых партий пока нет'),
        ),
        AsyncData(:final value) => ListView(
          children: [
            for (final game in value)
              Dismissible(
                key: ValueKey(game.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Theme.of(context).colorScheme.errorContainer,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Icon(Icons.delete),
                ),
                confirmDismiss: (_) => _confirmDelete(context),
                onDismissed: (_) =>
                    ref.read(gameProvider.notifier).deleteSaved(game.id),
                child: _SavedGameTile(
                  game,
                  onTap: () => _open(context, ref, game.id),
                ),
              ),
          ],
        ),
        AsyncError() => const Center(
          child: Text('Не удалось загрузить партии'),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _SavedGameTile extends StatelessWidget {
  const _SavedGameTile(this.game, {required this.onTap});

  final SavedGame game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final white = game.headers['White'];
    final black = game.headers['Black'];
    final players = white != null && white != '?' && black != null
        ? '$white — $black'
        : null;
    return ListTile(
      leading: Icon(game.result == '*' ? Icons.play_arrow : Icons.flag),
      title: Text(players ?? formatDateTime(game.createdAt)),
      subtitle: Text(
        [
          resultText(game.result),
          movesText(game.moveCount),
          if (players != null) formatDateTime(game.createdAt),
        ].join(' · '),
      ),
      onTap: onTap,
    );
  }
}

/// Результат из PGN словами.
String resultText(String result) => switch (result) {
  '1-0' => 'Победили белые',
  '0-1' => 'Победили чёрные',
  '1/2-1/2' => 'Ничья',
  _ => 'Не закончена',
};

/// Число ходов по полуходам: «1 ход», «3 хода», «12 ходов».
String movesText(int plies) {
  final n = (plies + 1) ~/ 2;
  final word = switch ((n % 10, n % 100)) {
    (1, != 11) => 'ход',
    (2 || 3 || 4, < 12 || > 14) => 'хода',
    _ => 'ходов',
  };
  return '$n $word';
}

/// «23.10.2026, 09:05».
String formatDateTime(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(date.day)}.${two(date.month)}.${date.year}, '
      '${two(date.hour)}:${two(date.minute)}';
}

class _PgnDialog extends StatefulWidget {
  const _PgnDialog();

  @override
  State<_PgnDialog> createState() => _PgnDialogState();
}

class _PgnDialogState extends State<_PgnDialog> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Импорт PGN'),
      content: TextField(
        controller: _text,
        autofocus: true,
        minLines: 4,
        maxLines: 8,
        decoration: const InputDecoration(
          hintText: '1. e4 e5 2. Nf3 Nc6 …',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _text.text),
          child: const Text('Открыть'),
        ),
      ],
    );
  }
}

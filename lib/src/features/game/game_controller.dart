import 'package:dartchess/dartchess.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../saved_games/saved_games_repository.dart';
import 'game.dart';

/// Текущая партия.
final gameProvider = NotifierProvider<GameController, Game>(GameController.new);

/// Текущая партия с автосохранением: каждое изменение записывается в базу,
/// поэтому партию можно продолжить после перезапуска приложения. Пустая
/// партия не сохраняется, пока в ней не сделан первый ход.
class GameController extends Notifier<Game> {
  /// Куда сохраняется текущая партия. Новая партия — новая запись.
  _SaveSlot _slot = _SaveSlot();

  /// Записи идут по очереди: следующая ждёт предыдущую, иначе первый ход
  /// мог бы создать партию дважды.
  Future<void> _saving = Future.value();

  @override
  Game build() => const Game();

  void play(Move move) => _update(state.play(move));

  void undo() => _update(state.undo());
  void redo() => _update(state.redo());
  void goTo(int ply) => _update(state.goTo(ply));

  /// Начинает новую партию: с начальной позиции или с [game].
  void start([Game? game]) {
    _slot = _SaveSlot();
    _update(game ?? const Game());
  }

  /// Продолжает сохранённую партию [id].
  void open(int id, Game game) {
    _slot = _SaveSlot(id);
    state = game;
  }

  /// Продолжает последнюю незаконченную партию, если она есть. Ошибка
  /// чтения базы не мешает запуску: начнётся новая партия.
  Future<void> restore() async {
    try {
      final last = await ref
          .read(savedGamesRepositoryProvider)
          .lastUnfinished();
      if (last != null) open(last.id, last.game);
    } on Object catch (error, stack) {
      _report(error, stack, 'restoring the last game');
    }
  }

  /// Завершается, когда все изменения записаны.
  Future<void> get saved => _saving;

  void _update(Game game) {
    state = game;
    // Репозиторий берём сразу: к моменту записи провайдер уже может быть
    // уничтожен (например, в конце теста).
    final repository = ref.read(savedGamesRepositoryProvider);
    final slot = _slot;
    _saving = _saving.then((_) => _save(repository, slot, game));
  }

  Future<void> _save(
    SavedGamesRepository repository,
    _SaveSlot slot,
    Game game,
  ) async {
    try {
      if (slot.id case final id?) {
        await repository.update(id, game);
      } else if (game.moves.isNotEmpty) {
        slot.id = await repository.create(game);
      }
    } on Object catch (error, stack) {
      _report(error, stack, 'saving the game');
    }
  }

  static void _report(Object error, StackTrace stack, String context) =>
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'chesslearn',
          context: ErrorDescription(context),
        ),
      );
}

class _SaveSlot {
  _SaveSlot([this.id]);

  int? id;
}

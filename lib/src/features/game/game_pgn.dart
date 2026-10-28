import 'package:dartchess/dartchess.dart';

import 'game.dart';

/// Записывает партию в PGN: все ходы, включая отменённые, — так сохраняется
/// вся партия, а не только позиция на доске.
///
/// `Result` считается по последнему ходу, `SetUp` и `FEN` пишутся, если
/// партия начата не с начальной позиции. Остальные заголовки — из
/// [headers] поверх стандартных («?»).
String gameToPgn(Game game, {PgnHeaders headers = const {}}) {
  final pgn = PgnGame<PgnNodeData>(
    headers: {
      ...PgnGame.defaultHeaders(),
      ...headers,
      'Result': Outcome.toPgnString(game.goTo(game.moves.length).outcome),
      if (game.start.fen != kInitialFEN) ...{
        'SetUp': '1',
        'FEN': game.start.fen,
      },
    },
    moves: PgnNode(),
    comments: const [],
  );
  var node = pgn.moves;
  for (final move in game.moves) {
    final child = PgnChildNode(PgnNodeData(san: move.san));
    node.children.add(child);
    node = child;
  }
  return pgn.makePgn();
}

/// Читает первую партию из PGN: только основную линию, варианты и
/// комментарии пропускаются. Доска стоит на последнем ходу.
///
/// Если `Result` — итог, а позиция партию не заканчивает, партия
/// закончилась без мата: победа считается сдачей проигравшего, ничья —
/// по соглашению. Так читаются и наши партии, и большинство турнирных;
/// поражение по времени PGN без заголовка `Termination` не отличить.
///
/// Бросает [FormatException], если PGN не для классических шахмат,
/// в нём некорректный FEN или нелегальный ход.
({Game game, PgnHeaders headers}) gameFromPgn(String pgn) {
  final parsed = PgnGame.parsePgn(pgn);
  if (Rule.fromPgn(parsed.headers['Variant']) != Rule.chess) {
    throw FormatException('Unsupported variant: ${parsed.headers['Variant']}');
  }
  Game game;
  try {
    game = Game(start: PgnGame.startingPosition(parsed.headers));
  } on Exception catch (e) {
    throw FormatException('Invalid FEN: $e');
  }
  for (final (index, data) in parsed.moves.mainline().indexed) {
    final move = game.position.parseSan(data.san);
    if (move == null) {
      throw FormatException('Illegal move ${index + 1}: ${data.san}');
    }
    game = game.play(move);
  }
  if (game.result == null) {
    game = switch (Outcome.fromPgn(parsed.headers['Result'])) {
      null => game,
      Outcome(winner: final winner?) => game.resign(winner.opposite),
      Outcome() => game.agreeDraw(),
    };
  }
  return (game: game, headers: parsed.headers);
}

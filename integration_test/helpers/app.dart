import 'package:chesslearn/src/app.dart';
import 'package:chesslearn/src/core/database.dart';
import 'package:chesslearn/src/features/game/game.dart';
import 'package:chesslearn/src/features/game/game_controller.dart';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

ProviderContainer? _running;
bool _surfaceConverted = false;

/// Запускает приложение, как `main.dart`, но со своим контейнером
/// провайдеров. Новый запуск закрывает предыдущий вместе с базой — как
/// перезапуск приложения: файл базы на устройстве остаётся тем же.
///
/// [clearSaved] — начать с пустой базой, чтобы сценарии не зависели друг от
/// друга и от прошлых запусков на устройстве.
Future<ProviderContainer> launchApp(
  WidgetTester tester, {
  bool clearSaved = true,
}) async {
  await _closeApp(tester);
  // Smoke-тест запускает настоящий main() со своей базой на тот же файл.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final container = ProviderContainer();
  _running = container;
  if (clearSaved) {
    final db = container.read(databaseProvider);
    await db.delete(db.savedGames).go();
  }
  await container.read(gameProvider.notifier).restore();
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const ChessLearnApp(),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Future<void> _closeApp(WidgetTester tester) async {
  final container = _running;
  if (container == null) return;
  _running = null;
  await container.read(gameProvider.notifier).saved;
  await tester.pumpWidget(const SizedBox.shrink());
  container.dispose();
}

/// Скриншот в `screenshots/<name>.png` (сохраняет драйвер `flutter drive`).
Future<void> screenshot(WidgetTester tester, String name) async {
  final binding = IntegrationTestWidgetsFlutterBinding.instance;
  // На Android Flutter рисует в отдельную поверхность, которую нельзя
  // сфотографировать: переключаем её один раз (повторный вызов — ошибка).
  // На iOS вызов ничего не делает.
  if (!_surfaceConverted) {
    await binding.convertFlutterSurfaceToImage();
    _surfaceConverted = true;
  }
  await tester.pumpAndSettle();
  await binding.takeScreenshot(name);
}

/// Открывает пункт главного меню.
Future<void> openFromMenu(WidgetTester tester, String title) async {
  await tester.tap(find.text(title));
  await tester.pumpAndSettle();
}

/// Текущая партия запущенного приложения.
Game currentGame() => _running!.read(gameProvider);

Chessboard board(WidgetTester tester) =>
    tester.widget<Chessboard>(find.byType(Chessboard));

/// Центр поля [name] на экране с учётом поворота доски.
Offset squareCenter(WidgetTester tester, String name) {
  final square = Square.fromName(name);
  final rect = tester.getRect(find.byType(Chessboard));
  final cell = rect.width / 8;
  final white = board(tester).orientation == Side.white;
  final file = white ? square.file : 7 - square.file;
  final row = white ? 7 - square.rank : square.rank;
  return rect.topLeft + Offset((file + 0.5) * cell, (row + 0.5) * cell);
}

Future<void> tapSquare(WidgetTester tester, String name) async {
  await tester.tapAt(squareCenter(tester, name));
  await tester.pumpAndSettle();
}

/// Ходы двумя касаниями (поле, откуда, и поле, куда) в UCI: `e2e4`.
Future<void> playMoves(WidgetTester tester, List<String> uci) async {
  for (final move in uci) {
    await tapSquare(tester, move.substring(0, 2));
    await tapSquare(tester, move.substring(2, 4));
  }
}

/// Ход перетаскиванием фигуры.
Future<void> dragPiece(WidgetTester tester, String from, String to) async {
  final start = squareCenter(tester, from);
  await tester.timedDragFrom(
    start,
    squareCenter(tester, to) - start,
    const Duration(milliseconds: 400),
  );
  await tester.pumpAndSettle();
}

/// Ходы партии в SAN.
List<String> sanMoves() => [for (final m in currentGame().moves) m.san];

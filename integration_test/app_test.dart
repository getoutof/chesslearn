import 'package:chesslearn/main.dart' as app;
import 'package:chesslearn/src/app.dart';
import 'package:chesslearn/src/features/hotseat/hotseat_screen.dart';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Smoke-тест на настоящем устройстве: приложение стартует, открывается
/// игра вдвоём, на доске проходит ход. Скриншоты сохраняет драйвер
/// (`test_driver/integration_test.dart`), поэтому запускать через
/// `flutter drive` — см. docs/CONFIG.md.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> screenshot(WidgetTester tester, String name) async {
    await tester.pumpAndSettle();
    await binding.takeScreenshot(name);
  }

  Future<void> tapSquare(WidgetTester tester, String name) async {
    final square = Square.fromName(name);
    final board = tester.getRect(find.byType(Chessboard));
    final cell = board.width / 8;
    await tester.tapAt(
      board.topLeft +
          Offset((square.file + 0.5) * cell, (7 - square.rank + 0.5) * cell),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('старт, игра вдвоём, ход e2–e4', (tester) async {
    app.main();
    // На Android Flutter рисует в отдельную поверхность, которую нельзя
    // сфотографировать: переключаем её один раз (повторный вызов — ошибка).
    // На iOS вызов ничего не делает.
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();

    expect(find.text(ChessLearnApp.title), findsOneWidget);
    await screenshot(tester, '01-home');

    await tester.tap(find.text(HotseatScreen.title));
    await tester.pumpAndSettle();
    expect(find.byType(Chessboard), findsOneWidget);
    await screenshot(tester, '02-hotseat');

    await tapSquare(tester, 'e2');
    await tapSquare(tester, 'e4');

    final board = tester.widget<Chessboard>(find.byType(Chessboard));
    expect(board.controller.lastMove, Move.parse('e2e4'));
    await screenshot(tester, '03-hotseat-e4');
  });
}

import 'package:chesslearn/main.dart' as app;
import 'package:chesslearn/src/app.dart';
import 'package:chesslearn/src/features/hotseat/hotseat_screen.dart';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/app.dart';
import 'scenarios/hotseat.dart';

/// Все интеграционные тесты — одним файлом: `flutter drive` собирает и
/// ставит приложение на каждый файл заново, а сборка — самое долгое.
/// Сценарии лежат в scenarios/. Скриншоты сохраняет драйвер
/// (`test_driver/integration_test.dart`), поэтому запускать через
/// `flutter drive` — см. docs/CONFIG.md.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Smoke-тест — первым: настоящий main(), пока на устройстве нет партий
  // от других сценариев, которые main() открыл бы при старте.
  testWidgets('старт, игра вдвоём, ход e2–e4', (tester) async {
    await app.main();
    await tester.pumpAndSettle();

    expect(find.text(ChessLearnApp.title), findsOneWidget);
    await screenshot(tester, '01-home');

    await openFromMenu(tester, HotseatScreen.title);
    expect(find.byType(Chessboard), findsOneWidget);
    await screenshot(tester, '02-hotseat');

    await playMoves(tester, ['e2e4']);
    expect(board(tester).controller.lastMove, Move.parse('e2e4'));
    await screenshot(tester, '03-hotseat-e4');
  });

  hotseatScenarios();
}

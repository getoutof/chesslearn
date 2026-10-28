import 'package:chesslearn/src/features/hotseat/hotseat_screen.dart';
import 'package:chesslearn/src/features/saved_games/saved_games_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app.dart';

/// «Партия в опере» (Морфи, 1858) с тегами, комментарием и вариантом.
const _operaGame = '''
[Event "Paris"]
[Date "1858.??.??"]
[White "Paul Morphy"]
[Black "Duke Karl / Count Isouard"]
[Result "1-0"]

1. e4 e5 2. Nf3 d6 {Защита Филидора} 3. d4 Bg4 (3... exd4 4. Nxd4) 4. dxe5
Bxf3 5. Qxf3 dxe5 6. Bc4 Nf6 7. Qb3 Qe7 8. Nc3 c6 9. Bg5 b5 10. Nxb5 cxb5
11. Bxb5+ Nbd7 12. O-O-O Rd8 13. Rxd7 Rxd7 14. Rd1 Qe6 15. Bxd7+ Nxd7
16. Qb8+ Nxb8 17. Rd8# 1-0
''';

/// E2E: сохранение и загрузка партий (#46). Сценарий «Поделиться» — последним
/// во всём прогоне: системное окно остаётся открытым, закрыть его из теста
/// нельзя.
void savedGamesScenarios() {
  group('сохранённые партии', () {
    Future<void> importPgn(WidgetTester tester, String pgn) async {
      await openFromMenu(tester, SavedGamesScreen.title);
      await tester.tap(find.byTooltip('Импорт PGN'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), pgn);
      await tester.tap(find.text('Открыть'));
      await tester.pumpAndSettle();
    }

    testWidgets('партия на месте после перезапуска приложения', (tester) async {
      await launchApp(tester);
      await openFromMenu(tester, HotseatScreen.title);
      await playMoves(tester, ['e2e4', 'e7e5', 'g1f3']);
      await tester.tap(find.byTooltip('Отменить ход'));
      await tester.pumpAndSettle();

      // Новый контейнер и новое подключение к файлу базы на устройстве.
      await launchApp(tester, clearSaved: false);
      await openFromMenu(tester, HotseatScreen.title);
      expect(sanMoves(), ['e4', 'e5', 'Nf3']);
      expect(currentGame().ply, 2);
      expect(find.text('Ход белых'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await openFromMenu(tester, SavedGamesScreen.title);
      expect(find.text('Не закончена · 2 хода'), findsOneWidget);
      await screenshot(tester, '46-01-saved-list');
    });

    testWidgets('импорт PGN с тегами, комментариями и вариантами', (
      tester,
    ) async {
      await launchApp(tester);
      await importPgn(tester, _operaGame);

      expect(find.byType(HotseatScreen), findsOneWidget);
      final moves = sanMoves();
      expect(moves, hasLength(33));
      expect(moves.take(4), ['e4', 'e5', 'Nf3', 'd6']);
      expect(moves.last, 'Rd8#');
      expect(find.text('Победили белые. Мат'), findsOneWidget);
      await screenshot(tester, '46-02-imported');

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(
        find.text('Paul Morphy — Duke Karl / Count Isouard'),
        findsOneWidget,
      );
    });

    testWidgets('повреждённый PGN — сообщение, приложение работает', (
      tester,
    ) async {
      await launchApp(tester);
      await importPgn(tester, '1. e4 e5 2. Ke3 Nc6 *');

      expect(find.text('Не удалось прочитать PGN'), findsOneWidget);
      expect(find.byType(SavedGamesScreen), findsOneWidget);
      expect(find.text('Сохранённых партий пока нет'), findsOneWidget);
      await screenshot(tester, '46-03-bad-pgn');
    });

    testWidgets('«Поделиться PGN» вызывает системное окно без ошибок', (
      tester,
    ) async {
      await launchApp(tester);
      await openFromMenu(tester, HotseatScreen.title);
      await playMoves(tester, ['e2e4']);
      await screenshot(tester, '46-04-before-share');

      await tester.tap(find.byType(PopupMenuButton<void>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Поделиться PGN'));
      // Системное окно — не Flutter: проверить его из теста нельзя, а
      // pumpAndSettle под ним на Android может не дождаться кадров.
      // Проверяем, что вызов дошёл до плагина без исключений.
      await tester.pump();
      await Future<void>.delayed(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
    }, timeout: const Timeout(Duration(minutes: 2)));
  });
}

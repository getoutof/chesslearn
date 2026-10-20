import 'package:chesslearn/src/features/home/home_screen.dart';
import 'package:chesslearn/src/features/hotseat/hotseat_screen.dart';
import 'package:chesslearn/src/features/placeholder/placeholder_screen.dart';
import 'package:chessground/chessground.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester) => tester.pumpWidget(
  const ProviderScope(child: MaterialApp(home: HomeScreen())),
);

Future<void> _open(WidgetTester tester, String item) async {
  await tester.tap(find.text(item));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('«Игра вдвоём» открывает доску, «назад» возвращает в меню', (
    tester,
  ) async {
    await _pump(tester);

    await _open(tester, HotseatScreen.title);
    expect(find.byType(HotseatScreen), findsOneWidget);
    expect(find.byType(Chessboard), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(Chessboard), findsNothing);
  });

  for (final (item, issue) in [
    ('Игра с компьютером', 11),
    ('Обучение', 13),
    ('Знаменитые партии', 21),
    ('Настройки', 4),
    ('О программе', 4),
  ]) {
    testWidgets('«$item» — заглушка со ссылкой на #$issue', (tester) async {
      await _pump(tester);

      await _open(tester, item);

      final screen = tester.widget<PlaceholderScreen>(
        find.byType(PlaceholderScreen),
      );
      expect(screen.title, item);
      expect(screen.issue, issue);
      expect(find.text('Задача #$issue'), findsOneWidget);
    });
  }
}

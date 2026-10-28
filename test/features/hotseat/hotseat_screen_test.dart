import 'package:chesslearn/src/features/game/game.dart';
import 'package:chesslearn/src/features/game/game_controller.dart';
import 'package:chesslearn/src/features/hotseat/board_orientation.dart';
import 'package:chesslearn/src/features/hotseat/hotseat_screen.dart';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_container.dart';

/// Открывает экран игры поверх экрана «Меню», как из главного меню.
Future<ProviderContainer> _pump(WidgetTester tester) async {
  final container = createTestContainer();
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: Text('Меню')),
    ),
  );
  tester
      .state<NavigatorState>(find.byType(Navigator))
      .push(MaterialPageRoute<void>(builder: (_) => const HotseatScreen()));
  await tester.pumpAndSettle();
  return container;
}

/// Позиция перед детским матом: чёрные ставят мат ходом Qd8-h4.
const _beforeMate =
    'rnbqkbnr/pppp1ppp/8/4p3/6P1/5P2/PPPPP2P/RNBQKBNR b KQkq - 0 2';

Future<void> _playUci(WidgetTester tester, String from, String to) async {
  await _tapSquare(tester, from);
  await _tapSquare(tester, to);
}

Future<void> _tapSquare(WidgetTester tester, String name) async {
  final square = Square.fromName(name);
  final board = tester.getRect(find.byType(Chessboard));
  final cell = board.width / 8;
  // У перевёрнутой доски a1 — в правом верхнем углу.
  final white = _board(tester).orientation == Side.white;
  final file = white ? square.file : 7 - square.file;
  final row = white ? 7 - square.rank : square.rank;
  await tester.tapAt(
    board.topLeft + Offset((file + 0.5) * cell, (row + 0.5) * cell),
  );
  await tester.pumpAndSettle();
}

Chessboard _board(WidgetTester tester) =>
    tester.widget<Chessboard>(find.byType(Chessboard));

void main() {
  testWidgets('ход на доске попадает в партию', (tester) async {
    final container = await _pump(tester);

    await _tapSquare(tester, 'e2');
    await _tapSquare(tester, 'e4');

    expect(container.read(gameProvider).moves.single.san, 'e4');
    expect(_board(tester).controller.lastMove, Move.parse('e2e4'));
  });

  testWidgets('после мата доска не принимает ходы', (tester) async {
    final container = await _pump(tester);
    container
        .read(gameProvider.notifier)
        .start(
          Game.fromFen(
            'rnb1kbnr/pppp1ppp/8/4p3/6Pq/5P2/PPPPP2P/RNBQKBNR w KQkq - 1 3',
          ),
        );
    await tester.pumpAndSettle();

    expect(container.read(gameProvider).isCheckmate, isTrue);
    expect(_board(tester).controller.interactive, isFalse);
  });

  testWidgets('индикатор показывает, чей ход и шах', (tester) async {
    final container = await _pump(tester);
    expect(find.text('Ход белых'), findsOneWidget);

    await _playUci(tester, 'e2', 'e4');
    expect(find.text('Ход чёрных'), findsOneWidget);

    container
        .read(gameProvider.notifier)
        .start(Game.fromFen('4k3/8/8/8/8/8/8/4KQ2 w - - 0 1'));
    await tester.pumpAndSettle();
    await _playUci(tester, 'f1', 'e2');
    expect(find.text('Ход чёрных — шах!'), findsOneWidget);
  });

  group('конец партии', () {
    Future<ProviderContainer> mate(WidgetTester tester) async {
      final container = await _pump(tester);
      container.read(gameProvider.notifier).start(Game.fromFen(_beforeMate));
      await tester.pumpAndSettle();
      await _playUci(tester, 'd8', 'h4');
      return container;
    }

    testWidgets('мат — окно результата', (tester) async {
      await mate(tester);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Победили чёрные'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('«К позиции» — итог над доской, ходить нельзя', (tester) async {
      await mate(tester);
      await tester.tap(find.text('К позиции'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Победили чёрные. Мат'), findsOneWidget);
      expect(_board(tester).controller.interactive, isFalse);
    });

    testWidgets('«Новая партия» — начальная позиция', (tester) async {
      final container = await mate(tester);
      await tester.tap(find.text('Новая партия'));
      await tester.pumpAndSettle();

      expect(container.read(gameProvider).fen, kInitialFEN);
      expect(find.text('Ход белых'), findsOneWidget);
    });

    testWidgets('«В меню» — возврат в главное меню', (tester) async {
      await mate(tester);
      await tester.tap(find.text('В меню'));
      await tester.pumpAndSettle();

      expect(find.byType(HotseatScreen), findsNothing);
      expect(find.text('Меню'), findsOneWidget);
    });

    testWidgets('ничья повторением — окно с причиной', (tester) async {
      await _pump(tester);
      for (var i = 0; i < 2; i++) {
        await _playUci(tester, 'g1', 'f3');
        await _playUci(tester, 'g8', 'f6');
        await _playUci(tester, 'f3', 'g1');
        await _playUci(tester, 'f6', 'g8');
      }

      expect(find.text('Ничья'), findsOneWidget);
      expect(find.text('Троекратное повторение позиции'), findsOneWidget);
    });
  });

  group('история ходов', () {
    IconButton button(WidgetTester tester, String tooltip) =>
        tester.widget<IconButton>(
          find.ancestor(
            of: find.byTooltip(tooltip),
            matching: find.byType(IconButton),
          ),
        );

    testWidgets('в начале партии кнопки неактивны', (tester) async {
      await _pump(tester);
      expect(find.text('Ходов пока нет'), findsOneWidget);
      for (final t in [
        'В начало',
        'Отменить ход',
        'Вернуть ход',
        'К последнему ходу',
      ]) {
        expect(button(tester, t).onPressed, isNull);
      }
    });

    testWidgets('отмена и возврат хода', (tester) async {
      final container = await _pump(tester);
      await _playUci(tester, 'e2', 'e4');
      await _playUci(tester, 'e7', 'e5');
      expect(find.text('1.'), findsOneWidget);

      await tester.tap(find.byTooltip('Отменить ход'));
      await tester.pumpAndSettle();
      expect(container.read(gameProvider).ply, 1);
      expect(_board(tester).controller.lastMove, Move.parse('e2e4'));
      expect(find.text('Ход чёрных'), findsOneWidget);

      await tester.tap(find.byTooltip('Вернуть ход'));
      await tester.pumpAndSettle();
      expect(container.read(gameProvider).ply, 2);

      await tester.tap(find.byTooltip('В начало'));
      await tester.pumpAndSettle();
      expect(container.read(gameProvider).fen, kInitialFEN);

      await tester.tap(find.byTooltip('К последнему ходу'));
      await tester.pumpAndSettle();
      expect(container.read(gameProvider).ply, 2);
    });

    testWidgets('нажатие на ход в списке — переход к нему', (tester) async {
      final container = await _pump(tester);
      await _playUci(tester, 'e2', 'e4');
      await _playUci(tester, 'e7', 'e5');

      await tester.tap(find.text('e4'));
      await tester.pumpAndSettle();
      expect(container.read(gameProvider).ply, 1);
    });

    testWidgets('номера ходов — от стартовой позиции', (tester) async {
      final container = await _pump(tester);
      container
          .read(gameProvider.notifier)
          .start(Game.fromFen('4k3/8/8/8/8/8/8/4K2R b K - 0 12'));
      await tester.pumpAndSettle();
      await _playUci(tester, 'e8', 'd7');
      await _playUci(tester, 'e1', 'g1');

      expect(find.text('12…'), findsOneWidget);
      expect(find.text('13.'), findsOneWidget);
      expect(find.text('O-O'), findsOneWidget);
    });

    testWidgets('отмена мата: доска снова принимает ходы, окно не '
        'появляется при возврате', (tester) async {
      final container = await _pump(tester);
      container.read(gameProvider.notifier).start(Game.fromFen(_beforeMate));
      await tester.pumpAndSettle();
      await _playUci(tester, 'd8', 'h4');
      await tester.tap(find.text('К позиции'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Отменить ход'));
      await tester.pumpAndSettle();
      expect(_board(tester).controller.interactive, isTrue);

      await tester.tap(find.byTooltip('Вернуть ход'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Победили чёрные. Мат'), findsOneWidget);
    });
  });

  group('переворот доски', () {
    testWidgets('кнопка переворачивает доску, ходы работают', (tester) async {
      final container = await _pump(tester);
      await tester.tap(find.byTooltip('Перевернуть доску'));
      await tester.pumpAndSettle();
      expect(_board(tester).orientation, Side.black);

      await _playUci(tester, 'e2', 'e4');
      expect(container.read(gameProvider).moves.single.san, 'e4');
      expect(_board(tester).orientation, Side.black);

      await tester.tap(find.byTooltip('Перевернуть доску'));
      await tester.pumpAndSettle();
      expect(_board(tester).orientation, Side.white);
    });

    testWidgets('автоповорот — внизу сторона, которая ходит', (tester) async {
      final container = await _pump(tester);
      await tester.tap(find.byType(PopupMenuButton<void>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Поворачивать доску после хода'));
      await tester.pumpAndSettle();
      expect(container.read(autoRotateProvider), isTrue);
      expect(_board(tester).orientation, Side.white);

      await _playUci(tester, 'e2', 'e4');
      expect(_board(tester).orientation, Side.black);
      await _playUci(tester, 'e7', 'e5');
      expect(_board(tester).orientation, Side.white);
    });
  });

  testWidgets('«Поделиться PGN» — PGN партии в окне «Поделиться»', (
    tester,
  ) async {
    final shared = <Object?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/share'),
      (call) async {
        shared.add(call.arguments);
        return 'dev.fluttercommunity.plus/share/unavailable';
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/share'),
        null,
      ),
    );
    await _pump(tester);
    await _playUci(tester, 'e2', 'e4');

    await tester.tap(find.byType(PopupMenuButton<void>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Поделиться PGN'));
    await tester.pumpAndSettle();

    final args = shared.single! as Map<Object?, Object?>;
    expect(args['text'], contains('1. e4 *'));
  });

  testWidgets('некорректный FEN — сообщение, партия не меняется', (
    tester,
  ) async {
    final container = await _pump(tester);

    await tester.tap(find.byTooltip('Позиция из FEN'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'not a fen');
    await tester.tap(find.text('Показать'));
    await tester.pumpAndSettle();

    expect(find.text('Некорректный FEN'), findsOneWidget);
    expect(container.read(gameProvider).fen, kInitialFEN);
  });
}

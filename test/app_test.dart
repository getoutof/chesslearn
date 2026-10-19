import 'package:chesslearn/src/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app starts on the home screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ChessLearnApp()));

    expect(find.text(ChessLearnApp.title), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}

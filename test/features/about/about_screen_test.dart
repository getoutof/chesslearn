import 'package:chesslearn/src/features/about/about_screen.dart';
import 'package:chesslearn/src/features/about/licenses.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<void> _pump(WidgetTester tester) async {
  PackageInfo.setMockInitialValues(
    appName: 'ChessLearn Dev',
    packageName: 'io.github.getoutof.chesslearn.dev',
    version: '0.1.0',
    buildNumber: '7',
    buildSignature: '',
  );
  await tester.pumpWidget(const MaterialApp(home: AboutScreen()));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('показывает версию, исходный код и лицензию', (tester) async {
    await _pump(tester);

    expect(find.text('Версия 0.1.0 (7)'), findsOneWidget);
    expect(find.text(AboutScreen.sourceUrl.toString()), findsOneWidget);
    expect(find.text('Лицензия GNU GPL v3'), findsOneWidget);
  });

  testWidgets('«Лицензии компонентов» открывает страницу лицензий', (
    tester,
  ) async {
    await _pump(tester);

    await tester.tap(find.text('Лицензии компонентов'));
    await tester.pumpAndSettle();

    expect(find.byType(LicensePage), findsOneWidget);
  });

  test('регистрирует лицензию приложения и атрибуцию фигур', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerLicenses();

    final entries = await LicenseRegistry.licenses.toList();
    final app = entries.singleWhere((e) => e.packages.contains('ChessLearn'));
    final text = app.paragraphs.map((p) => p.text).join('\n');
    expect(text, contains('GNU GENERAL PUBLIC LICENSE'));
    expect(text, contains('Version 3'));
    expect(
      entries.where((e) => e.packages.contains('Фигуры cburnett')),
      hasLength(1),
    );
  });
}

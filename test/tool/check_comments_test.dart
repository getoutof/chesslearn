import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_comments.dart';

List<String> _texts(String source, Syntax syntax) => [
  for (final c in extractComments(source, syntax)) c.text.trim(),
];

void main() {
  group('isRussian', () {
    test('русский текст, в том числе с английскими терминами', () {
      expect(isRussian('Подпись для flavor prod, см. docs/CONFIG.md'), isTrue);
    });

    test('английский текст', () {
      expect(isRussian('Placeholder home screen'), isFalse);
    });

    test('код, ссылки и [Идентификаторы] не считаются', () {
      expect(isRussian('`flutter pub get`'), isTrue);
      expect(isRussian('https://example.com/docs'), isTrue);
      expect(isRussian('[HomeScreen]'), isTrue);
      expect(isRussian('---'), isTrue);
    });
  });

  group('extractComments, Dart', () {
    test('находит //, /// и /* */', () {
      const source = '''
/// Док
int a = 1; // строка
/* блок */
''';
      expect(_texts(source, Syntax.cLike), ['Док', 'строка', 'блок']);
    });

    test('не принимает // внутри строк за комментарий', () {
      const source = r"""
final a = 'https://pub.dev';
final b = "x ${c ? 'a//b' : "d"} // still string";
final r = r'\'; // comment
final t = '''
// inside triple
''';
""";
      expect(_texts(source, Syntax.cLike), ['comment']);
    });

    test('склеивает соседние строки в один блок', () {
      const source =
          '// Пример:\n//   tool/remote.sh build apk\nint a;\n// b\n';
      final comments = extractComments(source, Syntax.cLike);
      expect(comments, hasLength(2));
      expect(comments.first.line, 1);
      expect(comments.first.endLine, 2);
    });

    test('пропускает директивы анализатора', () {
      expect(_texts('// ignore: avoid_print\n', Syntax.cLike), isEmpty);
    });
  });

  group('extractComments, # ', () {
    test('YAML и shell', () {
      const source = '''
#!/usr/bin/env bash
# shellcheck disable=SC2086
key: "value # not comment" # comment
echo \$# '#no' x#y
''';
      expect(_texts(source, Syntax.hash), ['comment']);
    });
  });

  group('checkSource', () {
    test('скрипт без расширения узнаётся по #!', () {
      expect(checkSource('tool/run', '#!/bin/sh\n# English\n'), hasLength(1));
      expect(checkSource('tool/data', '# English\n'), isEmpty);
    });

    test('сгенерированные файлы не проверяются', () {
      expect(checkSource('lib/a.g.dart', '// English\n'), isEmpty);
    });

    test('onlyLines ограничивает проверку изменёнными строками', () {
      const source = '# Template comment\nx: 1\n# Our comment\n';
      expect(checkSource('pubspec.yaml', source), hasLength(2));
      final onlyNew = checkSource('pubspec.yaml', source, onlyLines: {3});
      expect(onlyNew.single.comment.line, 3);
    });

    test('onlyLines не смешивает новые строки с шаблонными', () {
      const source = '# Template comment\n# Новый комментарий\n# New one\n';
      final violations = checkSource('pubspec.yaml', source, onlyLines: {3});
      expect(violations.single.comment.line, 3);
      expect(checkSource('pubspec.yaml', source, onlyLines: {2}), isEmpty);
    });
  });

  test('addedLines разбирает git diff --unified=0', () {
    final diff = [
      'diff --git a/pubspec.yaml b/pubspec.yaml',
      '--- a/pubspec.yaml',
      '+++ b/pubspec.yaml',
      '@@ -5 +5,2 @@ name',
      '@@ -20,0 +22 @@',
      '@@ -30,3 +31,0 @@',
    ];
    expect(addedLines(diff), {
      'pubspec.yaml': {5, 6, 22},
    });
  });
}

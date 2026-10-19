// Проверяет, что комментарии в нашем коде написаны по-русски.
//
//   dart run tool/check_comments.dart              # наши файлы целиком
//   dart run tool/check_comments.dart --base main  # плюс изменённые строки
//                                                  # в файлах из шаблона Flutter
//
// Какие файлы проверяются и почему — в docs/CONFIG.md.

import 'dart:io';

/// Файлы и папки, которые целиком наши: проверяются полностью.
const ownPaths = ['lib', 'test', 'tool', '.github', 'analysis_options.yaml'];

/// Наши файлы, созданные из шаблона Flutter: в них остались английские
/// комментарии шаблона, поэтому проверяются только строки, изменённые
/// относительно `--base`.
const mixedPaths = [
  'pubspec.yaml',
  'android/gradle.properties',
  'android/app/build.gradle.kts',
  'android/app/src/main/kotlin',
  'ios/Runner',
];

/// Сгенерированный код не проверяется, даже если лежит в наших папках.
final generatedPatterns = [
  RegExp(r'\.(g|freezed|gr|mocks)\.dart$'),
  RegExp(r'(^|/)generated_plugin_registrant\.dart$'),
  RegExp('GeneratedPluginRegistrant'),
  RegExp(r'^lib/(l10n/)?generated/'),
];

enum Syntax {
  /// `//`, `///` и `/* */`: Dart, Kotlin, Swift.
  cLike,

  /// `#`: YAML, shell-скрипты, properties.
  hash,
}

class Comment {
  Comment(this.line, this.endLine, this.text);

  final int line;
  final int endLine;
  final String text;
}

class Violation {
  Violation(this.path, this.comment);

  final String path;
  final Comment comment;

  @override
  String toString() {
    final preview = comment.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    final short = preview.length > 70
        ? '${preview.substring(0, 70)}…'
        : preview;
    return '$path:${comment.line}: комментарий не на русском: $short';
  }
}

Syntax? syntaxFor(String path) {
  final name = path.split('/').last.replaceFirst(RegExp(r'\.example$'), '');
  if (RegExp(r'\.(dart|kt|kts|swift|gradle|java|js|ts)$').hasMatch(name)) {
    return Syntax.cLike;
  }
  if (RegExp(r'(\.(ya?ml|sh|properties|toml)|^\.?\w*\.env)$').hasMatch(name)) {
    return Syntax.hash;
  }
  return null;
}

bool isGenerated(String path) => generatedPatterns.any((p) => p.hasMatch(path));

final _directive = RegExp(
  r'^\s*(ignore:|ignore_for_file:|shellcheck |coverage:|dart format |'
  r'swiftlint:|ktlint-|noinspection|@formatter:)',
);
final _cyrillic = RegExp('[а-яёА-ЯЁ]');
final _latin = RegExp('[A-Za-z]');

/// Комментарий подходит, если в нём есть русский текст или нет слов вовсе.
/// Код в обратных кавычках, ссылки и `[Идентификаторы]` не считаются.
bool isRussian(String text) {
  final prose = text
      .replaceAll(RegExp('`[^`]*`'), ' ')
      .replaceAll(RegExp(r'\w+://\S+'), ' ')
      .replaceAll(RegExp(r'\[[^\]\n]*\]'), ' ');
  return _cyrillic.hasMatch(prose) || !_latin.hasMatch(prose);
}

/// Находит комментарии. Соседние строчные комментарии одного вида
/// склеиваются в один блок: проверяется блок целиком.
List<Comment> extractComments(String source, Syntax syntax) {
  final raw = switch (syntax) {
    Syntax.cLike => (_CLexer(source)..scan()).comments,
    Syntax.hash => _hashComments(source),
  };
  final merged = <(String, Comment)>[];
  for (final (marker, c) in raw) {
    if (_directive.hasMatch(c.text)) continue;
    if (merged.isNotEmpty) {
      final (prevMarker, prev) = merged.last;
      if (marker != '/*' &&
          marker == prevMarker &&
          c.line == prev.endLine + 1) {
        merged.last = (
          marker,
          Comment(prev.line, c.endLine, '${prev.text}\n${c.text}'),
        );
        continue;
      }
    }
    merged.add((marker, c));
  }
  return [for (final (_, c) in merged) c];
}

/// Проверяет файл. Если задан [onlyLines], из каждого блока проверяются
/// только эти строки: соседние строки шаблона Flutter не учитываются.
List<Violation> checkSource(String path, String source, {Set<int>? onlyLines}) {
  // Скрипты без расширения (tool/remote.sh и т.п.) узнаём по `#!`.
  final syntax =
      syntaxFor(path) ?? (source.startsWith('#!') ? Syntax.hash : null);
  if (syntax == null || isGenerated(path)) return [];
  final violations = <Violation>[];
  for (final c in extractComments(source, syntax)) {
    final checked = onlyLines == null ? c : _onlyLines(c, onlyLines);
    if (checked != null && !isRussian(checked.text)) {
      violations.add(Violation(path, checked));
    }
  }
  return violations;
}

Comment? _onlyLines(Comment c, Set<int> lines) {
  final picked = <int, String>{
    for (final (i, text) in c.text.split('\n').indexed)
      if (lines.contains(c.line + i)) c.line + i: text,
  };
  if (picked.isEmpty) return null;
  return Comment(picked.keys.first, picked.keys.last, picked.values.join('\n'));
}

List<(String, Comment)> _hashComments(String source) {
  final result = <(String, Comment)>[];
  final lines = source.split('\n');
  for (var n = 0; n < lines.length; n++) {
    final line = lines[n];
    if (n == 0 && line.startsWith('#!')) continue;
    String? quote;
    for (var j = 0; j < line.length; j++) {
      final c = line[j];
      if (quote != null) {
        if (c == r'\' && quote == '"') {
          j++;
        } else if (c == quote) {
          quote = null;
        }
        continue;
      }
      final atTokenStart =
          j == 0 || RegExp(r'[\s=:(\[{,$]').hasMatch(line[j - 1]);
      if ((c == '"' || c == "'") && atTokenStart) {
        quote = c;
      } else if (c == '#' && (j == 0 || RegExp(r'\s').hasMatch(line[j - 1]))) {
        result.add(('#', Comment(n + 1, n + 1, line.substring(j + 1))));
        break;
      }
    }
  }
  return result;
}

/// Лексер для Dart/Kotlin/Swift: обходит строки (включая тройные, raw и
/// интерполяцию `${...}`), чтобы не принять `//` внутри строки за комментарий.
class _CLexer {
  _CLexer(this.s);

  final String s;
  final comments = <(String, Comment)>[];
  var _i = 0;
  var _line = 1;

  void scan() => _code(interpolation: false);

  void _code({required bool interpolation}) {
    var depth = 0;
    while (_i < s.length) {
      final c = s[_i];
      if (c == '\n') {
        _line++;
        _i++;
      } else if (s.startsWith('//', _i)) {
        _lineComment();
      } else if (s.startsWith('/*', _i)) {
        _blockComment();
      } else if (c == '"' || c == "'") {
        final raw =
            _i > 0 &&
            s[_i - 1] == 'r' &&
            (_i < 2 || !RegExp(r'\w').hasMatch(s[_i - 2]));
        _string(raw: raw);
      } else if (interpolation && c == '{') {
        depth++;
        _i++;
      } else if (interpolation && c == '}') {
        _i++;
        if (depth == 0) return;
        depth--;
      } else {
        _i++;
      }
    }
  }

  void _string({required bool raw}) {
    final q = s[_i];
    final close = s.startsWith(q * 3, _i) ? q * 3 : q;
    _i += close.length;
    while (_i < s.length) {
      if (s.startsWith(close, _i)) {
        _i += close.length;
        return;
      }
      final c = s[_i];
      if (c == '\n') {
        _line++;
        _i++;
        // Незакрытая однострочная строка: дальше уже код.
        if (close.length == 1) return;
      } else if (!raw && c == r'\') {
        if (_i + 1 < s.length && s[_i + 1] == '\n') _line++;
        _i += 2;
      } else if (!raw && s.startsWith(r'${', _i)) {
        _i += 2;
        _code(interpolation: true);
      } else {
        _i++;
      }
    }
  }

  void _lineComment() {
    final end = s.indexOf('\n', _i);
    final text = s.substring(_i, end == -1 ? s.length : end);
    final marker = text.startsWith('///') ? '///' : '//';
    comments.add((
      marker,
      Comment(_line, _line, text.substring(marker.length)),
    ));
    _i = end == -1 ? s.length : end;
  }

  void _blockComment() {
    final start = _line;
    final buffer = StringBuffer();
    var depth = 0;
    while (_i < s.length) {
      if (s.startsWith('/*', _i)) {
        depth++;
        _i += 2;
      } else if (s.startsWith('*/', _i)) {
        depth--;
        _i += 2;
        if (depth == 0) break;
      } else {
        if (s[_i] == '\n') _line++;
        buffer.write(s[_i]);
        _i++;
      }
    }
    comments.add(('/*', Comment(start, _line, buffer.toString())));
  }
}

List<String> _git(List<String> args) {
  final result = Process.runSync('git', args);
  if (result.exitCode != 0) {
    stderr.write(result.stderr);
    exit(2);
  }
  return (result.stdout as String)
      .split('\n')
      .where((l) => l.isNotEmpty)
      .toList();
}

/// Номера добавленных строк по файлам из `git diff --unified=0`.
Map<String, Set<int>> addedLines(List<String> diff) {
  final result = <String, Set<int>>{};
  String? path;
  final hunk = RegExp(r'^@@ -\S+ \+(\d+)(?:,(\d+))? @@');
  for (final line in diff) {
    if (line.startsWith('+++ ')) {
      path = line == '+++ /dev/null' ? null : line.substring(6);
    } else if (path != null) {
      final m = hunk.firstMatch(line);
      if (m == null) continue;
      final start = int.parse(m[1]!);
      final count = int.parse(m[2] ?? '1');
      result.putIfAbsent(path, () => {}).addAll([
        for (var l = start; l < start + count; l++) l,
      ]);
    }
  }
  return result;
}

void main(List<String> args) {
  String? base;
  if (args.length == 2 && args[0] == '--base') {
    base = args[1];
  } else if (args.isNotEmpty) {
    stderr.writeln(
      'Использование: dart run tool/check_comments.dart '
      '[--base <ref>]',
    );
    exit(64);
  }

  final violations = <Violation>[];
  final own = _git([
    'ls-files', '--cached', '--others', '--exclude-standard', '--', //
    ...ownPaths,
  ]).toSet();
  for (final path in own) {
    final file = File(path);
    if (!file.existsSync()) continue;
    violations.addAll(checkSource(path, file.readAsStringSync()));
  }

  if (base != null) {
    final diff = _git([
      'diff', '--unified=0', '--no-color', '$base...HEAD', '--', //
      ...mixedPaths,
    ]);
    for (final MapEntry(key: path, value: lines) in addedLines(diff).entries) {
      final file = File(path);
      if (!file.existsSync()) continue;
      violations.addAll(
        checkSource(path, file.readAsStringSync(), onlyLines: lines),
      );
    }
  }

  final github = Platform.environment['GITHUB_ACTIONS'] == 'true';
  for (final v in violations) {
    stdout.writeln(v);
    if (github) {
      stdout.writeln(
        '::error file=${v.path},line=${v.comment.line}::'
        'Комментарий не на русском',
      );
    }
  }
  if (violations.isNotEmpty) {
    stdout.writeln(
      '\nКомментарии в нашем коде пишем по-русски '
      '(CONTRIBUTING.md). Найдено: ${violations.length}.',
    );
    exit(1);
  }
}

# ChessLearn

Мобильное приложение (iOS, Android) для игры в шахматы и обучения:

- игра против компьютера (Stockfish) с уровнями сложности;
- игра вдвоём на одном телефоне;
- подсказки — 3 лучших хода (линии) с пояснениями;
- справки об исторических партиях, если позиция встречалась в известной партии.

Стек: Flutter, [flutter-chessground](https://github.com/lichess-org/flutter-chessground),
[dartchess](https://github.com/lichess-org/dartchess), [Stockfish](https://stockfishchess.org/).

План работ — в [Issues](https://github.com/getoutof/chesslearn/issues) и на
[доске проекта](https://github.com/users/getoutof/projects/2).

## Разработка

Версия Flutter зафиксирована в `pubspec.yaml` (`environment.flutter`).

```bash
flutter pub get
flutter run                   # flavor dev по умолчанию
flutter run --flavor prod
flutter analyze
flutter test
```

Две сборки — **dev** («ChessLearn Dev», ставится рядом с боевой) и **prod** («ChessLearn»).
Что за конфиги в проекте, что можно менять и чем отличаются dev и prod — в [docs/CONFIG.md](docs/CONFIG.md).

Структура кода:

```
lib/
  main.dart            точка входа
  src/
    app.dart           MaterialApp, темы, корневая навигация
    core/              общие вещи: тема, утилиты, базовые виджеты
    features/<name>/   экраны и логика по фичам (home, game, engine, ...)
    data/              хранилище, базы партий, репозитории
```

Состояние — [Riverpod](https://riverpod.dev/).

### CI

GitHub Actions на каждый push в `main` и каждый PR:

- `dart format`, `flutter analyze`, `flutter test`;
- сборка Android APK (dev) — скачать в артефактах запуска, `chesslearn-dev-apk`;
- проверочная сборка iOS (dev и prod) без подписи.

Версия Flutter берётся из `pubspec.yaml`.

## Лицензия

Исходный код распространяется под лицензией **GNU General Public License v3.0** — см. [LICENSE](LICENSE).

Это значит, что вы можете использовать, изменять и распространять код (в том числе за плату),
при условии что производные работы также распространяются под GPL-3.0 с открытым исходным кодом.

Список сторонних компонентов и их лицензий — в [THIRD_PARTY.md](THIRD_PARTY.md).

### Название и логотип

Лицензия GPL-3.0 не даёт прав на товарные знаки. Название «ChessLearn», логотип и иконка
приложения не входят в лицензию на код. Форки и модифицированные версии должны
распространяться под другим названием и с другим логотипом.

### Контент

Графика, звуки, тексты справок и другие ассеты могут распространяться под отдельными
лицензиями — они указываются рядом с соответствующими файлами и в [THIRD_PARTY.md](THIRD_PARTY.md).

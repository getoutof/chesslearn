# Сторонние компоненты

Список библиотек, движков и данных, используемых в ChessLearn, и их лицензии.
Обновляйте этот файл при добавлении каждой новой зависимости или ассета.

## Код

| Компонент | Назначение | Лицензия | Ссылка |
|---|---|---|---|
| Flutter | Фреймворк | BSD-3-Clause | https://github.com/flutter/flutter |
| flutter-chessground | Шахматная доска (UI) | GPL-3.0 | https://github.com/lichess-org/flutter-chessground |
| dartchess | Правила шахмат, FEN/PGN | GPL-3.0 | https://github.com/lichess-org/dartchess |
| Stockfish | Шахматный движок | GPL-3.0 | https://github.com/official-stockfish/Stockfish |
| multistockfish | Обёртка Stockfish для Flutter | GPL-3.0 | https://github.com/lichess-org/dart-multistockfish |
| package_info_plus | Версия приложения на экране «О программе» | BSD-3-Clause | https://github.com/fluttercommunity/plus_plugins |
| url_launcher | Открытие ссылок (исходный код, текст лицензии) в браузере | BSD-3-Clause | https://github.com/flutter/packages |
| drift, drift_flutter | База сохранённых партий | MIT | https://github.com/simolus3/drift |
| sqlite3 (Dart-пакет) | Доступ к SQLite, встраивает библиотеку SQLite в приложение | MIT | https://github.com/simolus3/sqlite3.dart |
| SQLite | Встроенная база данных | Public domain | https://sqlite.org/copyright.html |
| path_provider | Папка приложения для файла базы (через drift_flutter) | BSD-3-Clause | https://github.com/flutter/packages |
| share_plus | Окно «Поделиться» для PGN партии | BSD-3-Clause | https://github.com/fluttercommunity/plus_plugins |

## Данные

| Компонент | Назначение | Лицензия | Ссылка |
|---|---|---|---|
| chess-openings | Названия дебютов (ECO) | CC0-1.0 | https://github.com/lichess-org/chess-openings |

## Ассеты

| Ассет | Источник | Автор | Лицензия |
|---|---|---|---|
| Фигуры cburnett (используем) | пакет `chessground` | [Colin M.L. Burnett](https://en.wikipedia.org/wiki/User:Cburnett) | GPL-2.0-or-later ([lila COPYING.md](https://github.com/lichess-org/lila/blob/master/COPYING.md)) |

`chessground` включает в приложение **все** свои наборы фигур (~10 МБ), в том числе наборы под
CC BY-NC-SA (california, caliente, maestro и др.). Мы их не показываем, но они лежат в сборке —
разобрать до релиза в #26.

Для каждого набора фигур, звуков, шрифтов и текстов указывайте источник, автора и лицензию
(см. #26).

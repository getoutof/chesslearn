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

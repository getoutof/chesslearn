import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Добавляет на страницу лицензий то, что Flutter не собирает сам из
/// pub-пакетов: лицензию самого приложения и атрибуцию ассетов.
///
/// Stockfish и NNUE-сеть добавить сюда при подключении движка (#10), новые
/// ассеты — по мере появления (#26). Список должен совпадать с THIRD_PARTY.md.
void registerLicenses() {
  LicenseRegistry.addLicense(_licenses);
}

Stream<LicenseEntry> _licenses() async* {
  yield LicenseEntryWithLineBreaks([
    'ChessLearn',
  ], await rootBundle.loadString('LICENSE'));
  yield const LicenseEntryWithLineBreaks(
    ['Фигуры cburnett'],
    'Шахматные фигуры: Colin M.L. Burnett '
    '(https://en.wikipedia.org/wiki/User:Cburnett).\n\n'
    'Распространяются под лицензией GNU GPL версии 2 или более поздней '
    '(GPL-2.0-or-later), см. '
    'https://github.com/lichess-org/lila/blob/master/COPYING.md',
  );
}

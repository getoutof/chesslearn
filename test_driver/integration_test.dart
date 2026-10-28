import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Драйвер для `flutter drive`: запускает тесты из integration_test/ на
/// устройстве и сохраняет скриншоты в screenshots/<имя>.png.
Future<void> main() => integrationDriver(
  onScreenshot: (name, bytes, [args]) async {
    final file = File('screenshots/$name.png');
    await file.create(recursive: true);
    await file.writeAsBytes(bytes);
    return true;
  },
);

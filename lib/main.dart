import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';
import 'src/features/about/licenses.dart';
import 'src/features/game/game_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerLicenses();
  final container = ProviderContainer();
  // Незаконченная партия из прошлого запуска — до первого кадра, чтобы
  // экран игры сразу открылся с ней.
  await container.read(gameProvider.notifier).restore();
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const ChessLearnApp(),
    ),
  );
}

import 'package:chesslearn/src/core/database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Контейнер провайдеров с базой в памяти вместо файла на устройстве.
/// Закрывается в конце теста; unit-тесты, которые меняют партию, должны
/// сами дождаться `GameController.saved` (в widget-тестах запись успевает
/// за `pumpAndSettle`).
ProviderContainer createTestContainer() {
  final container = ProviderContainer(
    overrides: [databaseProvider.overrideWithValue(createTestDatabase())],
  );
  addTearDown(container.dispose);
  return container;
}

/// Пустая база в памяти; закрывается в конце теста.
AppDatabase createTestDatabase() {
  // В тестах базы создаются одна за другой — это не ошибка.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  return db;
}

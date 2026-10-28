import 'package:dartchess/dartchess.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Поворачивать доску после каждого хода к стороне, которая ходит.
///
/// Пока переключается в меню экрана игры и не сохраняется между запусками;
/// в настройки переедет в #41.
final autoRotateProvider = NotifierProvider<_Toggle, bool>(_Toggle.new);

/// Доска перевёрнута вручную относительно обычного положения.
final boardFlippedProvider = NotifierProvider<_Toggle, bool>(_Toggle.new);

class _Toggle extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

/// Чьи фигуры внизу: белые, при автоповороте — сторона, которая ходит;
/// ручной переворот меняет сторону на противоположную.
Side boardOrientation({
  required Side turn,
  required bool autoRotate,
  required bool flipped,
}) {
  final side = autoRotate ? turn : Side.white;
  return flipped ? side.opposite : side;
}

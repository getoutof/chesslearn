import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';
import 'src/features/about/licenses.dart';

void main() {
  registerLicenses();
  runApp(const ProviderScope(child: ChessLearnApp()));
}

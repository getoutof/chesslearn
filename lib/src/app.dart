import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'features/home/home_screen.dart';

class ChessLearnApp extends StatelessWidget {
  const ChessLearnApp({super.key});

  static const title = 'ChessLearn';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}

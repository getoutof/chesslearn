import 'package:flutter/material.dart';

import '../../app.dart';

/// Placeholder home screen. Real menu and navigation come in #4.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(ChessLearnApp.title)),
      body: Center(
        child: Text('♞', style: Theme.of(context).textTheme.displayLarge),
      ),
    );
  }
}

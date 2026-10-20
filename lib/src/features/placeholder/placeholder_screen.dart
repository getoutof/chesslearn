import 'package:flutter/material.dart';

/// Заглушка для раздела, который ещё не сделан: показывает, в какой задаче
/// он появится.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.issue,
  });

  final String title;

  /// Номер задачи на GitHub, в которой делается раздел.
  final int issue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.construction,
                size: 64,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text('Раздел в разработке', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('Задача #$issue', style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../app.dart';
import '../hotseat/hotseat_screen.dart';
import '../placeholder/placeholder_screen.dart';

/// Главное меню: режимы игры и служебные разделы.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(ChessLearnApp.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            _MenuItem(
              icon: Icons.computer,
              title: 'Игра с компьютером',
              subtitle: 'Уровни сложности от новичка до мастера',
              builder: (_) => const PlaceholderScreen(
                title: 'Игра с компьютером',
                issue: 11,
              ),
            ),
            _MenuItem(
              icon: Icons.people,
              title: HotseatScreen.title,
              subtitle: 'По очереди на одном телефоне',
              builder: (_) => const HotseatScreen(),
            ),
            _MenuItem(
              icon: Icons.school,
              title: 'Обучение',
              subtitle: 'Подсказки лучших ходов и разбор ошибок',
              builder: (_) =>
                  const PlaceholderScreen(title: 'Обучение', issue: 13),
            ),
            _MenuItem(
              icon: Icons.history_edu,
              title: 'Знаменитые партии',
              subtitle: 'Партии чемпионов с комментариями',
              builder: (_) => const PlaceholderScreen(
                title: 'Знаменитые партии',
                issue: 21,
              ),
            ),
            const Divider(),
            _MenuItem(
              icon: Icons.settings,
              title: 'Настройки',
              builder: (_) =>
                  const PlaceholderScreen(title: 'Настройки', issue: 41),
            ),
            _MenuItem(
              icon: Icons.info_outline,
              title: 'О программе',
              builder: (_) =>
                  const PlaceholderScreen(title: 'О программе', issue: 4),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.builder,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  /// Экран, который открывается по нажатию.
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: const Icon(Icons.chevron_right),
      onTap: () =>
          Navigator.of(context).push(MaterialPageRoute<void>(builder: builder)),
    );
  }
}

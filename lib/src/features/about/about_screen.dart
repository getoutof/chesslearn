import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app.dart';

/// «О программе»: версия, исходный код и лицензии. Экран обязателен по
/// GPL-3.0 (#9): пользователь должен знать лицензию и где взять исходники.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const title = 'О программе';
  static final sourceUrl = Uri.parse('https://github.com/getoutof/chesslearn');
  static final licenseUrl = Uri.parse(
    'https://www.gnu.org/licenses/gpl-3.0.html',
  );
  static const legalese =
      '© 2026 авторы ChessLearn\n'
      'Свободная программа под лицензией GNU GPL v3. '
      'Распространяется без каких-либо гарантий.';

  Future<void> _open(BuildContext context, Uri url) async {
    final opened = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Не удалось открыть $url')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text(title)),
      body: FutureBuilder(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final version = _version(snapshot.data);
          return ListView(
            children: [
              const SizedBox(height: 24),
              Text(
                ChessLearnApp.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
              Text(
                'Версия $version',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  legalese,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('Исходный код'),
                subtitle: Text(sourceUrl.toString()),
                onTap: () => _open(context, sourceUrl),
              ),
              ListTile(
                leading: const Icon(Icons.gavel),
                title: const Text('Лицензия GNU GPL v3'),
                subtitle: const Text('Текст лицензии на gnu.org'),
                onTap: () => _open(context, licenseUrl),
              ),
              ListTile(
                leading: const Icon(Icons.library_books),
                title: const Text('Лицензии компонентов'),
                subtitle: const Text('Библиотеки, движок, графика'),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: ChessLearnApp.title,
                  applicationVersion: version,
                  applicationLegalese: legalese,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Версия вида `0.1.0 (1)`; пока платформа не ответила — прочерк.
  static String _version(PackageInfo? info) {
    if (info == null) return '—';
    return info.buildNumber.isEmpty
        ? info.version
        : '${info.version} (${info.buildNumber})';
  }
}

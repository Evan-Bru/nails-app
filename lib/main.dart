import 'package:flutter/material.dart';

import 'package:esmalte/core/di/service_locator.dart';
import 'package:esmalte/core/theme/app_theme.dart';
import 'package:esmalte/views/root_shell.dart';

void main() {
  ServiceLocator.instance.init();
  runApp(const EsmalteApp());
}

/// Raiz do app: aplica o tema e abre a estrutura de navegação por abas
/// ([RootShell]).
class EsmalteApp extends StatelessWidget {
  const EsmalteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Esmalte',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const RootShell(),
    );
  }
}

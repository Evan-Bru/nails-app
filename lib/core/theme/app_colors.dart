import 'package:flutter/material.dart';

/// Paleta do Esmalte: vinho + dourado sobre um fundo claro
/// levemente rosado — evita o clichê "tudo rosa neon" sem perder
/// a identidade do universo de manicure/nail design.
class AppColors {
  AppColors._();

  static const background = Color(0xFFFBF5F3);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF0E4E0);

  static const textPrimary = Color(0xFF2E2129);
  static const textSecondary = Color(0xFF8A7880);

  static const primary = Color(0xFF7D3C4A);
  static const primaryLight = Color(0xFFA8677A);
  static const accent = Color(0xFFC9A15E);

  static const success = Color(0xFF6E8F63);
  static const danger = Color(0xFFB3554B);

  /// Paleta usada para diferenciar serviços na agenda — cada serviço
  /// recebe uma dessas cores para colorir seus blocos no calendário,
  /// igual ao padrão de cores por categoria da referência visual.
  static const serviceColors = <Color>[
    Color(0xFFC97B84),
    Color(0xFFD9A15C),
    Color(0xFFA78BA0),
    Color(0xFF7FA487),
    Color(0xFF7B99A8),
    Color(0xFFBF8F3E),
  ];
}

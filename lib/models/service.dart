import 'dart:ui' show Color;

/// Representa um serviço oferecido (manicure, pedicure, esmaltação em gel...).
///
/// Usa apenas `dart:ui` (não `package:flutter/material.dart`) para o tipo
/// [Color] — o suficiente para descrever a cor, sem acoplar a camada de
/// modelo ao framework de widgets.
class Service {
  final String id;
  final String name;
  final int durationMinutes;
  final double price;
  final Color color;

  const Service({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.price,
    required this.color,
  });

  Service copyWith({
    String? name,
    int? durationMinutes,
    double? price,
    Color? color,
  }) {
    return Service(
      id: id,
      name: name ?? this.name,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      price: price ?? this.price,
      color: color ?? this.color,
    );
  }
}

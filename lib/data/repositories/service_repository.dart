import 'dart:ui' show Color;

import 'package:esmalte/models/service.dart';

abstract class ServiceRepository {
  List<Service> getAll();
  Service? getById(String id);
  void add(Service service);
  void update(Service service);
  void delete(String id);
}

class InMemoryServiceRepository implements ServiceRepository {
  final List<Service> _services = [];

  // Mesma paleta usada em AppColors.serviceColors, repetida aqui de
  // propósito: a camada de dados não deve depender da camada de tema.
  static const _seedColors = <Color>[
    Color(0xFFC97B84),
    Color(0xFFD9A15C),
    Color(0xFFA78BA0),
    Color(0xFF7FA487),
    Color(0xFF7B99A8),
    Color(0xFFBF8F3E),
  ];

  InMemoryServiceRepository() {
    _seed();
  }

  void _seed() {
    _services.addAll([
      Service(
        id: 's1',
        name: 'Manicure Tradicional',
        durationMinutes: 45,
        price: 35,
        color: _seedColors[0],
      ),
      Service(
        id: 's2',
        name: 'Pedicure Tradicional',
        durationMinutes: 50,
        price: 40,
        color: _seedColors[1],
      ),
      Service(
        id: 's3',
        name: 'Esmaltação em Gel',
        durationMinutes: 60,
        price: 60,
        color: _seedColors[2],
      ),
      Service(
        id: 's4',
        name: 'Alongamento em Gel',
        durationMinutes: 120,
        price: 120,
        color: _seedColors[3],
      ),
      Service(
        id: 's5',
        name: 'Manicure + Pedicure',
        durationMinutes: 90,
        price: 70,
        color: _seedColors[4],
      ),
      Service(
        id: 's6',
        name: 'Nail Art (adicional)',
        durationMinutes: 30,
        price: 20,
        color: _seedColors[5],
      ),
    ]);
  }

  @override
  List<Service> getAll() => List<Service>.from(_services);

  @override
  Service? getById(String id) {
    for (final service in _services) {
      if (service.id == id) return service;
    }
    return null;
  }

  @override
  void add(Service service) => _services.add(service);

  @override
  void update(Service service) {
    final index = _services.indexWhere((s) => s.id == service.id);
    if (index != -1) _services[index] = service;
  }

  @override
  void delete(String id) => _services.removeWhere((s) => s.id == id);
}

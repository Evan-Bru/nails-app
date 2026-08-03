import 'dart:ui' show Color;

import 'package:esmalte/data/repositories/service_repository.dart';
import 'package:esmalte/models/service.dart';

abstract class ServiceFormView {
  void showService(Service service);
  void showValidationError(String message);
  void closeWithSuccess();
}

abstract class ServiceFormPresenter {
  void attachView(ServiceFormView view);
  void detachView();

  /// `serviceId` nulo significa "novo serviço".
  void loadService(String? serviceId);

  void save({
    required String name,
    required int durationMinutes,
    required double price,
    required Color color,
  });

  void delete();
}

class ServiceFormPresenterImpl implements ServiceFormPresenter {
  ServiceFormPresenterImpl({required ServiceRepository serviceRepository})
      : _serviceRepository = serviceRepository;

  final ServiceRepository _serviceRepository;
  ServiceFormView? _view;
  String? _editingId;

  @override
  void attachView(ServiceFormView view) => _view = view;

  @override
  void detachView() => _view = null;

  @override
  void loadService(String? serviceId) {
    _editingId = serviceId;
    if (serviceId == null) return;
    final service = _serviceRepository.getById(serviceId);
    if (service != null) _view?.showService(service);
  }

  @override
  void save({
    required String name,
    required int durationMinutes,
    required double price,
    required Color color,
  }) {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      _view?.showValidationError('Informe o nome do serviço.');
      return;
    }
    if (durationMinutes <= 0) {
      _view?.showValidationError('Informe uma duração válida.');
      return;
    }
    if (price < 0) {
      _view?.showValidationError('Informe um preço válido.');
      return;
    }

    if (_editingId == null) {
      final id = 's_${DateTime.now().microsecondsSinceEpoch}';
      _serviceRepository.add(Service(
        id: id,
        name: trimmedName,
        durationMinutes: durationMinutes,
        price: price,
        color: color,
      ));
    } else {
      final existing = _serviceRepository.getById(_editingId!);
      if (existing == null) {
        _view?.showValidationError('Serviço não encontrado.');
        return;
      }
      _serviceRepository.update(existing.copyWith(
        name: trimmedName,
        durationMinutes: durationMinutes,
        price: price,
        color: color,
      ));
    }

    _view?.closeWithSuccess();
  }

  @override
  void delete() {
    if (_editingId != null) {
      _serviceRepository.delete(_editingId!);
    }
    _view?.closeWithSuccess();
  }
}

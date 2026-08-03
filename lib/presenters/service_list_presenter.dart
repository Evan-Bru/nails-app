import 'package:esmalte/data/repositories/service_repository.dart';
import 'package:esmalte/models/service.dart';

abstract class ServiceListView {
  void showServices(List<Service> services);
}

abstract class ServiceListPresenter {
  void attachView(ServiceListView view);
  void detachView();
  void loadServices();
  void deleteService(String id);
}

class ServiceListPresenterImpl implements ServiceListPresenter {
  ServiceListPresenterImpl({required ServiceRepository serviceRepository})
      : _serviceRepository = serviceRepository;

  final ServiceRepository _serviceRepository;
  ServiceListView? _view;

  @override
  void attachView(ServiceListView view) => _view = view;

  @override
  void detachView() => _view = null;

  @override
  void loadServices() => _view?.showServices(_serviceRepository.getAll());

  @override
  void deleteService(String id) {
    _serviceRepository.delete(id);
    loadServices();
  }
}

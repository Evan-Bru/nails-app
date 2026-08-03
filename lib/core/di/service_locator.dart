import 'package:esmalte/data/repositories/appointment_repository.dart';
import 'package:esmalte/data/repositories/client_repository.dart';
import 'package:esmalte/data/repositories/service_repository.dart';

/// Localizador de serviços simples (sem pacote externo). Mantém uma
/// única instância de cada repositório durante a vida do app.
///
/// Views nunca instanciam repositórios diretamente — elas pedem ao
/// [ServiceLocator] e passam para o Presenter. Trocar a implementação
/// em memória por uma baseada em SQLite, por exemplo, é uma mudança
/// isolada aqui em [init].
class ServiceLocator {
  ServiceLocator._internal();

  static final ServiceLocator instance = ServiceLocator._internal();

  late final ClientRepository clientRepository;
  late final ServiceRepository serviceRepository;
  late final AppointmentRepository appointmentRepository;

  bool _initialized = false;

  void init() {
    if (_initialized) return;
    clientRepository = InMemoryClientRepository();
    serviceRepository = InMemoryServiceRepository();
    appointmentRepository = InMemoryAppointmentRepository();
    _initialized = true;
  }
}

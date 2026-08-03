import 'package:esmalte/core/utils/appointment_details_builder.dart';
import 'package:esmalte/data/repositories/appointment_repository.dart';
import 'package:esmalte/data/repositories/client_repository.dart';
import 'package:esmalte/data/repositories/service_repository.dart';
import 'package:esmalte/models/appointment_details.dart';
import 'package:esmalte/models/client.dart';

abstract class ClientFormView {
  void showClient(Client client);
  void showHistory(List<AppointmentDetails> history);
  void showValidationError(String message);
  void closeWithSuccess();
}

abstract class ClientFormPresenter {
  void attachView(ClientFormView view);
  void detachView();

  /// `clientId` nulo significa "nova cliente".
  void loadClient(String? clientId);

  void save({
    required String name,
    required String phone,
    DateTime? birthday,
    String? notes,
  });

  void delete();
}

class ClientFormPresenterImpl implements ClientFormPresenter {
  ClientFormPresenterImpl({
    required ClientRepository clientRepository,
    required AppointmentRepository appointmentRepository,
    required ServiceRepository serviceRepository,
  })  : _clientRepository = clientRepository,
        _appointmentRepository = appointmentRepository,
        _serviceRepository = serviceRepository;

  final ClientRepository _clientRepository;
  final AppointmentRepository _appointmentRepository;
  final ServiceRepository _serviceRepository;

  ClientFormView? _view;
  String? _editingId;

  @override
  void attachView(ClientFormView view) => _view = view;

  @override
  void detachView() => _view = null;

  @override
  void loadClient(String? clientId) {
    _editingId = clientId;
    if (clientId == null) return;

    final client = _clientRepository.getById(clientId);
    if (client == null) return;

    _view?.showClient(client);

    final history = buildAppointmentDetails(
      _appointmentRepository.getByClient(clientId),
      _clientRepository,
      _serviceRepository,
    )..sort((a, b) => b.start.compareTo(a.start));
    _view?.showHistory(history);
  }

  @override
  void save({
    required String name,
    required String phone,
    DateTime? birthday,
    String? notes,
  }) {
    final trimmedName = name.trim();
    final trimmedPhone = phone.trim();

    if (trimmedName.isEmpty) {
      _view?.showValidationError('Informe o nome da cliente.');
      return;
    }
    if (trimmedPhone.isEmpty) {
      _view?.showValidationError('Informe um telefone para contato.');
      return;
    }

    final trimmedNotes = notes?.trim();
    final hasNotes = trimmedNotes != null && trimmedNotes.isNotEmpty;

    if (_editingId == null) {
      final id = 'c_${DateTime.now().microsecondsSinceEpoch}';
      _clientRepository.add(Client(
        id: id,
        name: trimmedName,
        phone: trimmedPhone,
        birthday: birthday,
        notes: hasNotes ? trimmedNotes : null,
        createdAt: DateTime.now(),
      ));
    } else {
      final existing = _clientRepository.getById(_editingId!);
      if (existing == null) {
        _view?.showValidationError('Cliente não encontrada.');
        return;
      }
      _clientRepository.update(existing.copyWith(
        name: trimmedName,
        phone: trimmedPhone,
        birthday: birthday,
        clearBirthday: birthday == null,
        notes: hasNotes ? trimmedNotes : null,
        clearNotes: !hasNotes,
      ));
    }

    _view?.closeWithSuccess();
  }

  @override
  void delete() {
    if (_editingId != null) {
      _clientRepository.delete(_editingId!);
    }
    _view?.closeWithSuccess();
  }
}

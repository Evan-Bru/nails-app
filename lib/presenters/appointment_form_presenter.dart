import 'package:esmalte/data/repositories/appointment_repository.dart';
import 'package:esmalte/data/repositories/client_repository.dart';
import 'package:esmalte/data/repositories/service_repository.dart';
import 'package:esmalte/models/appointment.dart';
import 'package:esmalte/models/client.dart';
import 'package:esmalte/models/service.dart';

abstract class AppointmentFormView {
  void showClients(List<Client> clients);
  void showServices(List<Service> services);
  void showExistingAppointment(Appointment appointment);
  void showValidationError(String message);
  void closeWithSuccess();
}

abstract class AppointmentFormPresenter {
  void attachView(AppointmentFormView view);
  void detachView();

  /// `appointmentId` nulo significa "novo agendamento".
  void init({String? appointmentId});

  void save({
    required String clientId,
    required String serviceId,
    required DateTime dateTime,
    String? notes,
  });

  void markCompleted();
  void markCancelled();
  void delete();
}

class AppointmentFormPresenterImpl implements AppointmentFormPresenter {
  AppointmentFormPresenterImpl({
    required ClientRepository clientRepository,
    required ServiceRepository serviceRepository,
    required AppointmentRepository appointmentRepository,
  })  : _clientRepository = clientRepository,
        _serviceRepository = serviceRepository,
        _appointmentRepository = appointmentRepository;

  final ClientRepository _clientRepository;
  final ServiceRepository _serviceRepository;
  final AppointmentRepository _appointmentRepository;

  AppointmentFormView? _view;
  String? _editingId;

  @override
  void attachView(AppointmentFormView view) => _view = view;

  @override
  void detachView() => _view = null;

  @override
  void init({String? appointmentId}) {
    _editingId = appointmentId;
    _view?.showClients(_clientRepository.getAll());
    _view?.showServices(_serviceRepository.getAll());

    if (appointmentId != null) {
      final appointment = _appointmentRepository.getById(appointmentId);
      if (appointment != null) _view?.showExistingAppointment(appointment);
    }
  }

  /// Verifica se [start, end) esbarra em outro agendamento não cancelado
  /// do mesmo dia. Fica no Presenter (não no repositório) porque precisa
  /// cruzar Appointment com a duração do Service — informação de duas
  /// fontes diferentes.
  bool _hasConflict(DateTime start, DateTime end, {String? excludeId}) {
    final dayStart = DateTime(start.year, start.month, start.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final sameDay = _appointmentRepository.getBetween(dayStart, dayEnd);

    for (final appointment in sameDay) {
      if (appointment.id == excludeId) continue;
      if (appointment.status == AppointmentStatus.cancelled) continue;

      final service = _serviceRepository.getById(appointment.serviceId);
      final otherEnd = appointment.dateTime
          .add(Duration(minutes: service?.durationMinutes ?? 30));

      final overlaps =
          start.isBefore(otherEnd) && appointment.dateTime.isBefore(end);
      if (overlaps) return true;
    }
    return false;
  }

  @override
  void save({
    required String clientId,
    required String serviceId,
    required DateTime dateTime,
    String? notes,
  }) {
    if (clientId.isEmpty) {
      _view?.showValidationError('Selecione uma cliente.');
      return;
    }

    final service = _serviceRepository.getById(serviceId);
    if (service == null) {
      _view?.showValidationError('Selecione um serviço.');
      return;
    }

    final end = dateTime.add(Duration(minutes: service.durationMinutes));
    if (_hasConflict(dateTime, end, excludeId: _editingId)) {
      _view?.showValidationError(
          'Esse horário conflita com outro agendamento. Escolha outro horário.');
      return;
    }

    final trimmedNotes = notes?.trim();
    final hasNotes = trimmedNotes != null && trimmedNotes.isNotEmpty;

    if (_editingId == null) {
      final id = 'a_${DateTime.now().microsecondsSinceEpoch}';
      _appointmentRepository.add(Appointment(
        id: id,
        clientId: clientId,
        serviceId: serviceId,
        dateTime: dateTime,
        notes: hasNotes ? trimmedNotes : null,
      ));
    } else {
      final existing = _appointmentRepository.getById(_editingId!);
      if (existing == null) {
        _view?.showValidationError('Agendamento não encontrado.');
        return;
      }
      _appointmentRepository.update(existing.copyWith(
        clientId: clientId,
        serviceId: serviceId,
        dateTime: dateTime,
        notes: hasNotes ? trimmedNotes : null,
        clearNotes: !hasNotes,
      ));
    }

    _view?.closeWithSuccess();
  }

  @override
  void markCompleted() => _updateStatus(AppointmentStatus.completed);

  @override
  void markCancelled() => _updateStatus(AppointmentStatus.cancelled);

  void _updateStatus(AppointmentStatus status) {
    if (_editingId == null) return;
    final existing = _appointmentRepository.getById(_editingId!);
    if (existing == null) return;
    _appointmentRepository.update(existing.copyWith(status: status));
    _view?.closeWithSuccess();
  }

  @override
  void delete() {
    if (_editingId != null) {
      _appointmentRepository.delete(_editingId!);
    }
    _view?.closeWithSuccess();
  }
}

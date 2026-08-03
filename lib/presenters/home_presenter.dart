import 'package:esmalte/core/utils/appointment_details_builder.dart';
import 'package:esmalte/core/utils/formatters.dart';
import 'package:esmalte/data/repositories/appointment_repository.dart';
import 'package:esmalte/data/repositories/client_repository.dart';
import 'package:esmalte/data/repositories/service_repository.dart';
import 'package:esmalte/models/appointment.dart';
import 'package:esmalte/models/appointment_details.dart';

/// Contrato que a tela Início deve implementar. O Presenter só conhece
/// esta interface — nunca o widget concreto.
abstract class HomeView {
  void showSummary({
    required int appointmentsToday,
    required double expectedRevenueToday,
    required int totalClients,
    required List<AppointmentDetails> upcomingToday,
    required String greetingDate,
  });
}

abstract class HomePresenter {
  void attachView(HomeView view);
  void detachView();
  void loadSummary();
}

class HomePresenterImpl implements HomePresenter {
  HomePresenterImpl({
    required ClientRepository clientRepository,
    required ServiceRepository serviceRepository,
    required AppointmentRepository appointmentRepository,
  })  : _clientRepository = clientRepository,
        _serviceRepository = serviceRepository,
        _appointmentRepository = appointmentRepository;

  final ClientRepository _clientRepository;
  final ServiceRepository _serviceRepository;
  final AppointmentRepository _appointmentRepository;

  HomeView? _view;

  @override
  void attachView(HomeView view) => _view = view;

  @override
  void detachView() => _view = null;

  @override
  void loadSummary() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final todayAppointments = _appointmentRepository
        .getBetween(startOfDay, endOfDay)
        .where((a) => a.status != AppointmentStatus.cancelled)
        .toList();

    final details = buildAppointmentDetails(
      todayAppointments,
      _clientRepository,
      _serviceRepository,
    );

    final revenue =
        details.fold<double>(0, (sum, d) => sum + (d.service?.price ?? 0));

    final upcoming = details
        .where((d) =>
            d.start.isAfter(now) &&
            d.appointment.status == AppointmentStatus.scheduled)
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    _view?.showSummary(
      appointmentsToday: todayAppointments.length,
      expectedRevenueToday: revenue,
      totalClients: _clientRepository.getAll().length,
      upcomingToday: upcoming,
      greetingDate: AppFormatters.fullDate(now),
    );
  }
}

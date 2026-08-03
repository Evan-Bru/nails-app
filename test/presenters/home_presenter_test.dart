import 'package:esmalte/data/repositories/appointment_repository.dart';
import 'package:esmalte/data/repositories/client_repository.dart';
import 'package:esmalte/data/repositories/service_repository.dart';
import 'package:esmalte/models/appointment.dart';
import 'package:esmalte/models/appointment_details.dart';
import 'package:esmalte/presenters/home_presenter.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeHomeView implements HomeView {
  int? appointmentsToday;
  double? expectedRevenueToday;
  int? totalClients;
  List<AppointmentDetails>? upcomingToday;
  String? greetingDate;

  @override
  void showSummary({
    required int appointmentsToday,
    required double expectedRevenueToday,
    required int totalClients,
    required List<AppointmentDetails> upcomingToday,
    required String greetingDate,
  }) {
    this.appointmentsToday = appointmentsToday;
    this.expectedRevenueToday = expectedRevenueToday;
    this.totalClients = totalClients;
    this.upcomingToday = upcomingToday;
    this.greetingDate = greetingDate;
  }
}

void main() {
  group('HomePresenter', () {
    late InMemoryAppointmentRepository appointmentRepository;
    late HomePresenterImpl presenter;
    late _FakeHomeView view;

    setUp(() {
      appointmentRepository = InMemoryAppointmentRepository();
      // Limpo os dados de exemplo para controlar exatamente o que cai no dia.
      for (final appointment in appointmentRepository.getAll()) {
        appointmentRepository.delete(appointment.id);
      }

      presenter = HomePresenterImpl(
        clientRepository: InMemoryClientRepository(),
        serviceRepository: InMemoryServiceRepository(),
        appointmentRepository: appointmentRepository,
      );
      view = _FakeHomeView();
      presenter.attachView(view);
    });

    test('conta agendamentos de hoje ignorando os cancelados', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 10);

      appointmentRepository.add(Appointment(
        id: 'a1',
        clientId: 'c1',
        serviceId: 's1', // R$ 35
        dateTime: today,
      ));
      appointmentRepository.add(Appointment(
        id: 'a2',
        clientId: 'c2',
        serviceId: 's1', // R$ 35
        dateTime: today.add(const Duration(hours: 1)),
        status: AppointmentStatus.cancelled,
      ));

      presenter.loadSummary();

      // Só o não cancelado entra na contagem e na receita.
      expect(view.appointmentsToday, 1);
      expect(view.expectedRevenueToday, 35);
      expect(view.totalClients, 7);
      expect(view.greetingDate, isNotNull);
    });

    test('próximos horários trazem só os agendados ainda por vir', () {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      // Um já passou (início do dia) e outro ainda vai acontecer.
      appointmentRepository.add(Appointment(
        id: 'passado',
        clientId: 'c1',
        serviceId: 's1',
        dateTime: startOfDay,
      ));
      final futuro = now.add(const Duration(hours: 2));
      // Mantenho no mesmo dia para entrar na janela de "hoje".
      if (futuro.day == now.day) {
        appointmentRepository.add(Appointment(
          id: 'futuro',
          clientId: 'c2',
          serviceId: 's1',
          dateTime: futuro,
        ));
      }

      presenter.loadSummary();

      final ids = view.upcomingToday!.map((d) => d.appointment.id).toList();
      expect(ids, isNot(contains('passado')));
    });
  });
}

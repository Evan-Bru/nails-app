import 'package:esmalte/data/repositories/appointment_repository.dart';
import 'package:esmalte/data/repositories/client_repository.dart';
import 'package:esmalte/data/repositories/service_repository.dart';
import 'package:esmalte/models/appointment.dart';
import 'package:esmalte/models/appointment_details.dart';
import 'package:esmalte/presenters/agenda_presenter.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAgendaView implements AgendaView {
  List<DateTime>? workingDays;
  List<AppointmentDetails>? appointments;
  String? weekLabel;

  @override
  void showWeek({
    required List<DateTime> workingDays,
    required List<AppointmentDetails> appointments,
    required String weekLabel,
  }) {
    this.workingDays = workingDays;
    this.appointments = appointments;
    this.weekLabel = weekLabel;
  }
}

void main() {
  group('AgendaPresenter', () {
    late InMemoryAppointmentRepository appointmentRepository;
    late AgendaPresenterImpl presenter;
    late _FakeAgendaView view;

    setUp(() {
      appointmentRepository = InMemoryAppointmentRepository();
      // Começo de uma base limpa: os dados de exemplo caem na semana atual e
      // atrapalhariam as asserções sobre uma semana fixa.
      for (final appointment in appointmentRepository.getAll()) {
        appointmentRepository.delete(appointment.id);
      }

      presenter = AgendaPresenterImpl(
        clientRepository: InMemoryClientRepository(),
        serviceRepository: InMemoryServiceRepository(),
        appointmentRepository: appointmentRepository,
      );
      view = _FakeAgendaView();
      presenter.attachView(view);
    });

    test('mostra 6 dias úteis começando na segunda-feira', () {
      // 04/06/2030 é uma terça — a semana deve começar na segunda 03/06.
      presenter.loadWeekContaining(DateTime(2030, 6, 4));

      expect(view.workingDays, hasLength(6));
      expect(view.workingDays!.first, DateTime(2030, 6, 3));
      expect(view.workingDays!.first.weekday, DateTime.monday);
      expect(view.workingDays!.last, DateTime(2030, 6, 8)); // sábado
      expect(view.weekLabel, isNotNull);
    });

    test('inclui só os agendamentos da semana pedida', () {
      appointmentRepository.add(Appointment(
        id: 'in',
        clientId: 'c1',
        serviceId: 's1',
        dateTime: DateTime(2030, 6, 5, 10),
      ));
      appointmentRepository.add(Appointment(
        id: 'out',
        clientId: 'c1',
        serviceId: 's1',
        dateTime: DateTime(2030, 6, 20, 10),
      ));

      presenter.loadWeekContaining(DateTime(2030, 6, 4));

      final ids = view.appointments!.map((d) => d.appointment.id).toList();
      expect(ids, contains('in'));
      expect(ids, isNot(contains('out')));
    });

    test('goToNextWeek avança sete dias', () {
      presenter.loadWeekContaining(DateTime(2030, 6, 4));
      final firstDay = view.workingDays!.first;

      presenter.goToNextWeek();

      expect(
        view.workingDays!.first,
        firstDay.add(const Duration(days: 7)),
      );
    });
  });
}

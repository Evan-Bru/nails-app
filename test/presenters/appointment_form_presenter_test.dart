import 'package:flutter_test/flutter_test.dart';

import 'package:esmalte/data/repositories/appointment_repository.dart';
import 'package:esmalte/data/repositories/client_repository.dart';
import 'package:esmalte/data/repositories/service_repository.dart';
import 'package:esmalte/models/appointment.dart';
import 'package:esmalte/models/client.dart';
import 'package:esmalte/models/service.dart';
import 'package:esmalte/presenters/appointment_form_presenter.dart';

/// View falsa, sem nenhum widget — só grava o que o Presenter mandou
/// exibir. É exatamente esse desacoplamento que faz o MVP valer a pena:
/// dá pra testar "esse horário conflita, então não deve salvar" sem
/// montar uma árvore de widgets.
class _FakeView implements AppointmentFormView {
  String? lastError;
  bool closed = false;

  @override
  void showClients(List<Client> clients) {}

  @override
  void showServices(List<Service> services) {}

  @override
  void showExistingAppointment(Appointment appointment) {}

  @override
  void showValidationError(String message) {
    lastError = message;
  }

  @override
  void closeWithSuccess() {
    closed = true;
  }
}

void main() {
  group('AppointmentFormPresenter', () {
    late InMemoryClientRepository clientRepository;
    late InMemoryServiceRepository serviceRepository;
    late InMemoryAppointmentRepository appointmentRepository;
    late AppointmentFormPresenterImpl presenter;
    late _FakeView view;

    setUp(() {
      clientRepository = InMemoryClientRepository();
      serviceRepository = InMemoryServiceRepository();
      appointmentRepository = InMemoryAppointmentRepository();

      // Os agendamentos de exemplo do repositório são gerados relativos a
      // "agora" (pra sempre aparecerem "essa semana" na Agenda). Isso é
      // ótimo pra demo, mas indesejado num teste, que precisa de datas
      // previsíveis — então começamos de uma base limpa aqui.
      for (final appointment in appointmentRepository.getAll()) {
        appointmentRepository.delete(appointment.id);
      }

      presenter = AppointmentFormPresenterImpl(
        clientRepository: clientRepository,
        serviceRepository: serviceRepository,
        appointmentRepository: appointmentRepository,
      );
      view = _FakeView();
      presenter.attachView(view);
      presenter.init();
    });

    test('recusa salvar sem cliente selecionado', () {
      final service = serviceRepository.getAll().first;

      presenter.save(
        clientId: '',
        serviceId: service.id,
        dateTime: DateTime(2030, 6, 4, 10, 0),
      );

      expect(view.lastError, isNotNull);
      expect(view.closed, isFalse);
    });

    test('detecta conflito com um agendamento existente no mesmo horário', () {
      final client = clientRepository.getAll().first;
      final service =
          serviceRepository.getAll().first; // 45 min nos dados de exemplo
      final start = DateTime(2030, 6, 4, 10, 0);

      presenter.save(
          clientId: client.id, serviceId: service.id, dateTime: start);
      expect(view.closed, isTrue,
          reason: 'o primeiro agendamento deveria salvar normalmente');

      view.closed = false;
      final overlapping = start.add(const Duration(minutes: 15));
      presenter.save(
          clientId: client.id, serviceId: service.id, dateTime: overlapping);

      expect(view.lastError, contains('conflita'));
      expect(view.closed, isFalse);
    });

    test('permite agendar em outro horário livre no mesmo dia', () {
      final client = clientRepository.getAll().first;
      final service = serviceRepository.getAll().first;
      final start = DateTime(2030, 6, 4, 10, 0);

      presenter.save(
          clientId: client.id, serviceId: service.id, dateTime: start);

      view.closed = false;
      final later = start.add(const Duration(hours: 2));
      presenter.save(
          clientId: client.id, serviceId: service.id, dateTime: later);

      expect(view.closed, isTrue);
    });
  });
}

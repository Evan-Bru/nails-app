import 'package:esmalte/core/utils/appointment_details_builder.dart';
import 'package:esmalte/core/utils/formatters.dart';
import 'package:esmalte/data/repositories/appointment_repository.dart';
import 'package:esmalte/data/repositories/client_repository.dart';
import 'package:esmalte/data/repositories/service_repository.dart';
import 'package:esmalte/models/appointment_details.dart';

abstract class AgendaView {
  void showWeek({
    required List<DateTime> workingDays,
    required List<AppointmentDetails> appointments,
    required String weekLabel,
  });
}

abstract class AgendaPresenter {
  void attachView(AgendaView view);
  void detachView();
  void loadWeekContaining(DateTime date);
  void goToNextWeek();
  void goToPreviousWeek();
  void goToToday();

  /// Recarrega a semana atualmente exibida, sem mudar a referência —
  /// útil ao voltar de uma tela de agendamento sem perder a navegação.
  void refresh();
}

class AgendaPresenterImpl implements AgendaPresenter {
  AgendaPresenterImpl({
    required ClientRepository clientRepository,
    required ServiceRepository serviceRepository,
    required AppointmentRepository appointmentRepository,
  })  : _clientRepository = clientRepository,
        _serviceRepository = serviceRepository,
        _appointmentRepository = appointmentRepository;

  final ClientRepository _clientRepository;
  final ServiceRepository _serviceRepository;
  final AppointmentRepository _appointmentRepository;

  AgendaView? _view;
  DateTime _referenceDate = DateTime.now();

  // A manicure atende de segunda a sábado (fecha domingo) — um padrão comum
  // no setor. Ajustar aqui se o negócio funcionar em outros dias.
  static const int _workingDaysCount = 6;

  @override
  void attachView(AgendaView view) => _view = view;

  @override
  void detachView() => _view = null;

  DateTime _startOfWeek(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return d.subtract(Duration(days: d.weekday - DateTime.monday));
  }

  @override
  void loadWeekContaining(DateTime date) {
    _referenceDate = date;
    _emitWeek();
  }

  @override
  void goToNextWeek() {
    _referenceDate = _referenceDate.add(const Duration(days: 7));
    _emitWeek();
  }

  @override
  void goToPreviousWeek() {
    _referenceDate = _referenceDate.subtract(const Duration(days: 7));
    _emitWeek();
  }

  @override
  void goToToday() {
    _referenceDate = DateTime.now();
    _emitWeek();
  }

  @override
  void refresh() => _emitWeek();

  void _emitWeek() {
    final weekStart = _startOfWeek(_referenceDate);
    final workingDays = List.generate(
      _workingDaysCount,
      (i) => weekStart.add(Duration(days: i)),
    );
    final weekEnd = weekStart.add(const Duration(days: 7));

    final appointments = _appointmentRepository.getBetween(weekStart, weekEnd);
    final details = buildAppointmentDetails(
      appointments,
      _clientRepository,
      _serviceRepository,
    );

    _view?.showWeek(
      workingDays: workingDays,
      appointments: details,
      weekLabel: _weekLabel(weekStart, workingDays.last),
    );
  }

  String _weekLabel(DateTime weekStart, DateTime weekEnd) {
    if (weekStart.month == weekEnd.month) {
      return '${weekStart.day} – ${weekEnd.day} de ${AppFormatters.monthName(weekStart)}';
    }
    return '${weekStart.day} de ${AppFormatters.monthName(weekStart)} – '
        '${weekEnd.day} de ${AppFormatters.monthName(weekEnd)}';
  }
}

import 'package:esmalte/models/appointment.dart';

abstract class AppointmentRepository {
  List<Appointment> getAll();
  Appointment? getById(String id);

  /// Retorna agendamentos com `dateTime` em [start, endExclusive).
  List<Appointment> getBetween(DateTime start, DateTime endExclusive);

  List<Appointment> getByClient(String clientId);

  void add(Appointment appointment);
  void update(Appointment appointment);
  void delete(String id);
}

class InMemoryAppointmentRepository implements AppointmentRepository {
  final List<Appointment> _appointments = [];

  InMemoryAppointmentRepository() {
    _seed();
  }

  /// Calcula a próxima data com o [weekday] informado (1=segunda ... 7=domingo),
  /// a partir de [from], na semana atual ou seguinte. Usado só para gerar
  /// dados de exemplo que sempre caem "essa semana" quando o app é aberto.
  DateTime _nextWeekday(DateTime from, int weekday,
      {int hour = 9, int minute = 0}) {
    var date = DateTime(from.year, from.month, from.day, hour, minute);
    while (date.weekday != weekday) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  void _seed() {
    final today = DateTime.now();

    _appointments.addAll([
      Appointment(
        id: 'a1',
        clientId: 'c1',
        serviceId: 's1',
        dateTime: _nextWeekday(today, DateTime.tuesday, hour: 9),
      ),
      Appointment(
        id: 'a2',
        clientId: 'c2',
        serviceId: 's3',
        dateTime: _nextWeekday(today, DateTime.tuesday, hour: 11),
      ),
      Appointment(
        id: 'a3',
        clientId: 'c3',
        serviceId: 's2',
        dateTime: _nextWeekday(today, DateTime.wednesday, hour: 10),
      ),
      Appointment(
        id: 'a4',
        clientId: 'c4',
        serviceId: 's4',
        dateTime: _nextWeekday(today, DateTime.wednesday, hour: 14),
      ),
      Appointment(
        id: 'a5',
        clientId: 'c5',
        serviceId: 's1',
        dateTime: _nextWeekday(today, DateTime.thursday, hour: 9, minute: 30),
      ),
      Appointment(
        id: 'a6',
        clientId: 'c6',
        serviceId: 's5',
        dateTime: _nextWeekday(today, DateTime.friday, hour: 13),
      ),
      Appointment(
        id: 'a7',
        clientId: 'c7',
        serviceId: 's3',
        dateTime: _nextWeekday(today, DateTime.friday, hour: 16),
        notes: 'Pediu tom mais claro da última vez',
      ),
      Appointment(
        id: 'a8',
        clientId: 'c1',
        serviceId: 's6',
        dateTime: _nextWeekday(today, DateTime.saturday, hour: 10),
      ),
      Appointment(
        id: 'a9',
        clientId: 'c2',
        serviceId: 's2',
        dateTime: _nextWeekday(today, DateTime.saturday, hour: 11, minute: 30),
        status: AppointmentStatus.completed,
      ),
      Appointment(
        id: 'a10',
        clientId: 'c3',
        serviceId: 's1',
        dateTime: _nextWeekday(today, DateTime.saturday, hour: 15),
        status: AppointmentStatus.cancelled,
      ),
    ]);
  }

  @override
  List<Appointment> getAll() {
    final list = List<Appointment>.from(_appointments);
    list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return list;
  }

  @override
  Appointment? getById(String id) {
    for (final appointment in _appointments) {
      if (appointment.id == id) return appointment;
    }
    return null;
  }

  @override
  List<Appointment> getBetween(DateTime start, DateTime endExclusive) {
    return getAll()
        .where((a) =>
            !a.dateTime.isBefore(start) && a.dateTime.isBefore(endExclusive))
        .toList();
  }

  @override
  List<Appointment> getByClient(String clientId) {
    return getAll().where((a) => a.clientId == clientId).toList();
  }

  @override
  void add(Appointment appointment) => _appointments.add(appointment);

  @override
  void update(Appointment appointment) {
    final index = _appointments.indexWhere((a) => a.id == appointment.id);
    if (index != -1) _appointments[index] = appointment;
  }

  @override
  void delete(String id) => _appointments.removeWhere((a) => a.id == id);
}

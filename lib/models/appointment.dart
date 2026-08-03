enum AppointmentStatus { scheduled, completed, cancelled }

extension AppointmentStatusLabel on AppointmentStatus {
  String get label {
    switch (this) {
      case AppointmentStatus.scheduled:
        return 'Agendado';
      case AppointmentStatus.completed:
        return 'Concluído';
      case AppointmentStatus.cancelled:
        return 'Cancelado';
    }
  }
}

/// Representa um horário marcado: uma cliente, um serviço, uma data/hora.
///
/// A duração não é armazenada aqui — ela vem do [Service] associado
/// (`serviceId`), então o mesmo serviço sempre reflete a mesma duração
/// em todos os agendamentos que o usam.
class Appointment {
  final String id;
  final String clientId;
  final String serviceId;
  final DateTime dateTime;
  final AppointmentStatus status;
  final String? notes;

  const Appointment({
    required this.id,
    required this.clientId,
    required this.serviceId,
    required this.dateTime,
    this.status = AppointmentStatus.scheduled,
    this.notes,
  });

  Appointment copyWith({
    String? clientId,
    String? serviceId,
    DateTime? dateTime,
    AppointmentStatus? status,
    String? notes,
    bool clearNotes = false,
  }) {
    return Appointment(
      id: id,
      clientId: clientId ?? this.clientId,
      serviceId: serviceId ?? this.serviceId,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      notes: clearNotes ? null : (notes ?? this.notes),
    );
  }
}

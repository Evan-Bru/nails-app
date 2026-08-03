import 'package:esmalte/models/appointment.dart';
import 'package:esmalte/models/client.dart';
import 'package:esmalte/models/service.dart';

/// Combina um [Appointment] com os dados da [Client] e do [Service]
/// já resolvidos, para que a View nunca precise fazer lookups sozinha.
///
/// É montado pelos Presenters (veja `core/utils/appointment_details_builder.dart`)
/// a partir dos repositórios — a View apenas consome o resultado pronto.
class AppointmentDetails {
  final Appointment appointment;
  final Client? client;
  final Service? service;

  const AppointmentDetails({
    required this.appointment,
    required this.client,
    required this.service,
  });

  DateTime get start => appointment.dateTime;

  DateTime get end => appointment.dateTime
      .add(Duration(minutes: service?.durationMinutes ?? 30));

  String get clientName => client?.name ?? 'Cliente removida';

  String get serviceName => service?.name ?? 'Serviço removido';
}

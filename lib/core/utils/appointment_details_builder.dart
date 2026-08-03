import 'package:esmalte/data/repositories/client_repository.dart';
import 'package:esmalte/data/repositories/service_repository.dart';
import 'package:esmalte/models/appointment.dart';
import 'package:esmalte/models/appointment_details.dart';

/// Resolve cliente e serviço de cada [Appointment], produzindo uma lista de
/// [AppointmentDetails] pronta para exibição. Compartilhada por todos os
/// Presenters que precisam mostrar agendamentos (Home, Agenda, histórico
/// de cliente), para não repetir a mesma junção em cada um.
List<AppointmentDetails> buildAppointmentDetails(
  List<Appointment> appointments,
  ClientRepository clientRepository,
  ServiceRepository serviceRepository,
) {
  return appointments.map((appointment) {
    return AppointmentDetails(
      appointment: appointment,
      client: clientRepository.getById(appointment.clientId),
      service: serviceRepository.getById(appointment.serviceId),
    );
  }).toList();
}

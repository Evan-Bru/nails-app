import 'dart:ui' show Color;

import 'package:esmalte/models/appointment.dart';
import 'package:esmalte/models/appointment_details.dart';
import 'package:esmalte/models/client.dart';
import 'package:esmalte/models/service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Client.copyWith', () {
    final client = Client(
      id: 'c1',
      name: 'Camila',
      phone: '(71) 90000-0000',
      birthday: DateTime(1990, 5, 20),
      notes: 'Prefere gel',
      createdAt: DateTime(2024, 1, 1),
    );

    test('troca só o campo informado e preserva id/createdAt', () {
      final updated = client.copyWith(name: 'Camila Ferreira');

      expect(updated.id, 'c1');
      expect(updated.name, 'Camila Ferreira');
      expect(updated.phone, client.phone);
      expect(updated.birthday, client.birthday);
      expect(updated.notes, client.notes);
      expect(updated.createdAt, client.createdAt);
    });

    test('clearBirthday e clearNotes zeram os opcionais', () {
      final updated = client.copyWith(clearBirthday: true, clearNotes: true);

      expect(updated.birthday, isNull);
      expect(updated.notes, isNull);
    });
  });

  group('Appointment.copyWith', () {
    final appointment = Appointment(
      id: 'a1',
      clientId: 'c1',
      serviceId: 's1',
      dateTime: _fixed,
      notes: 'Tom mais claro',
    );

    test('muda o status preservando o resto', () {
      final updated = appointment.copyWith(status: AppointmentStatus.completed);

      expect(updated.status, AppointmentStatus.completed);
      expect(updated.id, 'a1');
      expect(updated.notes, 'Tom mais claro');
    });

    test('clearNotes remove a observação', () {
      final updated = appointment.copyWith(clearNotes: true);
      expect(updated.notes, isNull);
    });
  });

  group('AppointmentStatus.label', () {
    test('rótulos em português', () {
      expect(AppointmentStatus.scheduled.label, 'Agendado');
      expect(AppointmentStatus.completed.label, 'Concluído');
      expect(AppointmentStatus.cancelled.label, 'Cancelado');
    });
  });

  group('AppointmentDetails', () {
    const service = Service(
      id: 's1',
      name: 'Esmaltação em Gel',
      durationMinutes: 60,
      price: 60,
      color: Color(0xFFC97B84),
    );
    final client = Client(
      id: 'c1',
      name: 'Camila',
      phone: '000',
      createdAt: DateTime(2024, 1, 1),
    );
    final appointment = Appointment(
      id: 'a1',
      clientId: 'c1',
      serviceId: 's1',
      dateTime: _fixed,
    );

    test('end soma a duração do serviço ao início', () {
      final details = AppointmentDetails(
        appointment: appointment,
        client: client,
        service: service,
      );

      expect(details.end, _fixed.add(const Duration(minutes: 60)));
      expect(details.clientName, 'Camila');
      expect(details.serviceName, 'Esmaltação em Gel');
    });

    test('usa 30 min e rótulos de fallback quando faltam dados', () {
      final details = AppointmentDetails(
        appointment: appointment,
        client: null,
        service: null,
      );

      expect(details.end, _fixed.add(const Duration(minutes: 30)));
      expect(details.clientName, 'Cliente removida');
      expect(details.serviceName, 'Serviço removido');
    });
  });
}

final DateTime _fixed = DateTime(2030, 6, 4, 10, 0);

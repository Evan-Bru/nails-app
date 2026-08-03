import 'package:flutter/material.dart';

import 'package:esmalte/core/di/service_locator.dart';
import 'package:esmalte/models/appointment_details.dart';
import 'package:esmalte/presenters/agenda_presenter.dart';
import 'package:esmalte/views/agenda/week_calendar_grid.dart';
import 'package:esmalte/views/appointment_form/appointment_form_screen.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> implements AgendaView {
  late final AgendaPresenter _presenter;

  List<DateTime> _workingDays = [];
  List<AppointmentDetails> _appointments = [];
  String _weekLabel = '';

  @override
  void initState() {
    super.initState();
    _presenter = AgendaPresenterImpl(
      clientRepository: ServiceLocator.instance.clientRepository,
      serviceRepository: ServiceLocator.instance.serviceRepository,
      appointmentRepository: ServiceLocator.instance.appointmentRepository,
    );
    _presenter.attachView(this);
    _presenter.loadWeekContaining(DateTime.now());
  }

  @override
  void dispose() {
    _presenter.detachView();
    super.dispose();
  }

  @override
  void showWeek({
    required List<DateTime> workingDays,
    required List<AppointmentDetails> appointments,
    required String weekLabel,
  }) {
    setState(() {
      _workingDays = workingDays;
      _appointments = appointments;
      _weekLabel = weekLabel;
    });
  }

  Future<void> _openAppointmentForm(
      {String? appointmentId, DateTime? initialDateTime}) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AppointmentFormScreen(
        appointmentId: appointmentId,
        initialDateTime: initialDateTime,
      ),
    ));
    _presenter.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        actions: [
          TextButton(
              onPressed: _presenter.goToToday, child: const Text('HOJE')),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _presenter.goToPreviousWeek,
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    _weekLabel,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: _presenter.goToNextWeek,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: WeekCalendarGrid(
                workingDays: _workingDays,
                appointments: _appointments,
                onSlotTap: (day, time) =>
                    _openAppointmentForm(initialDateTime: time),
                onAppointmentTap: (details) =>
                    _openAppointmentForm(appointmentId: details.appointment.id),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAppointmentForm(),
        icon: const Icon(Icons.add),
        label: const Text('Novo'),
      ),
    );
  }
}

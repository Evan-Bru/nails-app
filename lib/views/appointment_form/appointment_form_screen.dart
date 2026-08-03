import 'package:flutter/material.dart';

import 'package:esmalte/core/di/service_locator.dart';
import 'package:esmalte/core/theme/app_colors.dart';
import 'package:esmalte/core/utils/formatters.dart';
import 'package:esmalte/models/appointment.dart';
import 'package:esmalte/models/client.dart';
import 'package:esmalte/models/service.dart';
import 'package:esmalte/presenters/appointment_form_presenter.dart';
import 'package:esmalte/widgets/confirm_dialog.dart';
import 'package:esmalte/widgets/picker_field.dart';

class AppointmentFormScreen extends StatefulWidget {
  const AppointmentFormScreen(
      {super.key, this.appointmentId, this.initialDateTime});

  final String? appointmentId;
  final DateTime? initialDateTime;

  @override
  State<AppointmentFormScreen> createState() => _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends State<AppointmentFormScreen>
    implements AppointmentFormView {
  late final AppointmentFormPresenter _presenter;
  final _notesController = TextEditingController();

  List<Client> _clients = [];
  List<Service> _services = [];

  String? _selectedClientId;
  String? _selectedServiceId;
  DateTime _date = DateTime.now();
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  AppointmentStatus _status = AppointmentStatus.scheduled;

  bool get _isEditing => widget.appointmentId != null;

  @override
  void initState() {
    super.initState();
    _presenter = AppointmentFormPresenterImpl(
      clientRepository: ServiceLocator.instance.clientRepository,
      serviceRepository: ServiceLocator.instance.serviceRepository,
      appointmentRepository: ServiceLocator.instance.appointmentRepository,
    );
    _presenter.attachView(this);

    if (widget.initialDateTime != null) {
      _date = widget.initialDateTime!;
      _time = TimeOfDay(
        hour: widget.initialDateTime!.hour,
        minute: widget.initialDateTime!.minute,
      );
    }

    _presenter.init(appointmentId: widget.appointmentId);
  }

  @override
  void dispose() {
    _presenter.detachView();
    _notesController.dispose();
    super.dispose();
  }

  @override
  void showClients(List<Client> clients) => setState(() => _clients = clients);

  @override
  void showServices(List<Service> services) =>
      setState(() => _services = services);

  @override
  void showExistingAppointment(Appointment appointment) {
    setState(() {
      _selectedClientId = appointment.clientId;
      _selectedServiceId = appointment.serviceId;
      _date = appointment.dateTime;
      _time = TimeOfDay(
          hour: appointment.dateTime.hour, minute: appointment.dateTime.minute);
      _notesController.text = appointment.notes ?? '';
      _status = appointment.status;
    });
  }

  @override
  void showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  @override
  void closeWithSuccess() {
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  void _save() {
    if (_selectedClientId == null) {
      showValidationError('Selecione uma cliente.');
      return;
    }
    if (_selectedServiceId == null) {
      showValidationError('Selecione um serviço.');
      return;
    }
    final dateTime =
        DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
    _presenter.save(
      clientId: _selectedClientId!,
      serviceId: _selectedServiceId!,
      dateTime: dateTime,
      notes: _notesController.text,
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Remover agendamento?',
      content: 'Essa ação não pode ser desfeita.',
    );
    if (confirmed) _presenter.delete();
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleSmall;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar agendamento' : 'Novo agendamento'),
        actions: [
          if (_isEditing)
            IconButton(
                onPressed: _confirmDelete,
                icon: const Icon(Icons.delete_outline)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Cliente', style: titleStyle),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedClientId,
            hint: const Text('Selecione a cliente'),
            isExpanded: true,
            items: _clients
                .map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name, overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _selectedClientId = value),
          ),
          const SizedBox(height: 20),
          Text('Serviço', style: titleStyle),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedServiceId,
            hint: const Text('Selecione o serviço'),
            isExpanded: true,
            items: _services
                .map((s) => DropdownMenuItem(
                      value: s.id,
                      child: Text(
                        '${s.name} · ${s.durationMinutes} min · ${AppFormatters.currency(s.price)}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _selectedServiceId = value),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: PickerField(
                  label: 'Data',
                  value: AppFormatters.shortDate(_date),
                  icon: Icons.calendar_today_outlined,
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PickerField(
                  label: 'Horário',
                  value: _time.format(context),
                  icon: Icons.access_time,
                  onTap: _pickTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Observações', style: titleStyle),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Preferências, alergias, pedidos especiais...',
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50)),
            child: const Text('Salvar agendamento'),
          ),
          if (_isEditing && _status == AppointmentStatus.scheduled) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _presenter.markCompleted,
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50)),
              child: const Text('Marcar como concluído'),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: _presenter.markCancelled,
                child: const Text('Cancelar agendamento'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

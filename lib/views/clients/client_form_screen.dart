import 'package:flutter/material.dart';

import 'package:esmalte/core/di/service_locator.dart';
import 'package:esmalte/core/utils/formatters.dart';
import 'package:esmalte/models/appointment_details.dart';
import 'package:esmalte/models/client.dart';
import 'package:esmalte/presenters/client_form_presenter.dart';
import 'package:esmalte/widgets/app_card.dart';
import 'package:esmalte/widgets/confirm_dialog.dart';
import 'package:esmalte/widgets/picker_field.dart';
import 'package:esmalte/widgets/status_badge.dart';
import 'package:esmalte/core/theme/app_colors.dart';

class ClientFormScreen extends StatefulWidget {
  const ClientFormScreen({super.key, this.clientId});

  final String? clientId;

  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen>
    implements ClientFormView {
  late final ClientFormPresenter _presenter;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _birthday;
  List<AppointmentDetails> _history = [];

  bool get _isEditing => widget.clientId != null;

  @override
  void initState() {
    super.initState();
    _presenter = ClientFormPresenterImpl(
      clientRepository: ServiceLocator.instance.clientRepository,
      appointmentRepository: ServiceLocator.instance.appointmentRepository,
      serviceRepository: ServiceLocator.instance.serviceRepository,
    );
    _presenter.attachView(this);
    _presenter.loadClient(widget.clientId);
  }

  @override
  void dispose() {
    _presenter.detachView();
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  void showClient(Client client) {
    setState(() {
      _nameController.text = client.name;
      _phoneController.text = client.phone;
      _notesController.text = client.notes ?? '';
      _birthday = client.birthday;
    });
  }

  @override
  void showHistory(List<AppointmentDetails> history) {
    setState(() => _history = history);
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

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthday = picked);
  }

  void _save() {
    _presenter.save(
      name: _nameController.text,
      phone: _phoneController.text,
      birthday: _birthday,
      notes: _notesController.text,
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Remover ${_nameController.text}?',
      content: 'O histórico de agendamentos dessa cliente também será perdido. '
          'Essa ação não pode ser desfeita.',
    );
    if (confirmed) _presenter.delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar cliente' : 'Nova cliente'),
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
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nome'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Telefone'),
          ),
          const SizedBox(height: 16),
          PickerField(
            label: 'Data de nascimento (opcional)',
            value: _birthday != null
                ? AppFormatters.fullDate(_birthday!)
                : 'Não informado',
            icon: Icons.cake_outlined,
            onTap: _pickBirthday,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Observações',
              hintText: 'Alergias, preferências...',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50)),
            child: const Text('Salvar'),
          ),
          if (_isEditing && _history.isNotEmpty) ...[
            const SizedBox(height: 32),
            Text('Histórico de agendamentos',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            ..._history.map((h) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                h.serviceName,
                                style: Theme.of(context).textTheme.titleMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${AppFormatters.fullDate(h.start)} às ${AppFormatters.time(h.start)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(status: h.appointment.status),
                      ],
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:esmalte/core/di/service_locator.dart';
import 'package:esmalte/core/theme/app_colors.dart';
import 'package:esmalte/models/service.dart';
import 'package:esmalte/presenters/service_form_presenter.dart';
import 'package:esmalte/widgets/confirm_dialog.dart';

class ServiceFormScreen extends StatefulWidget {
  const ServiceFormScreen({super.key, this.serviceId});

  final String? serviceId;

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen>
    implements ServiceFormView {
  late final ServiceFormPresenter _presenter;
  final _nameController = TextEditingController();
  final _durationController = TextEditingController(text: '45');
  final _priceController = TextEditingController();

  Color _selectedColor = AppColors.serviceColors.first;

  bool get _isEditing => widget.serviceId != null;

  @override
  void initState() {
    super.initState();
    _presenter = ServiceFormPresenterImpl(
        serviceRepository: ServiceLocator.instance.serviceRepository);
    _presenter.attachView(this);
    _presenter.loadService(widget.serviceId);
  }

  @override
  void dispose() {
    _presenter.detachView();
    _nameController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  void showService(Service service) {
    setState(() {
      _nameController.text = service.name;
      _durationController.text = service.durationMinutes.toString();
      _priceController.text =
          service.price.toStringAsFixed(2).replaceAll('.', ',');
      _selectedColor = service.color;
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

  Future<void> _confirmDelete() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Remover serviço?',
      content:
          'Agendamentos que já usam esse serviço mantêm o registro, mas ele deixa '
          'de aparecer para novos agendamentos.',
    );
    if (confirmed) _presenter.delete();
  }

  void _save() {
    final duration = int.tryParse(_durationController.text.trim()) ?? 0;
    final priceText =
        _priceController.text.trim().replaceAll('.', '').replaceAll(',', '.');
    final price = double.tryParse(priceText) ?? -1;
    _presenter.save(
      name: _nameController.text,
      durationMinutes: duration,
      price: price,
      color: _selectedColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar serviço' : 'Novo serviço'),
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
            decoration: const InputDecoration(labelText: 'Nome do serviço'),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Duração (min)'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _priceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Preço (R\$)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Cor de identificação',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: AppColors.serviceColors.map((color) {
              final isSelected = color == _selectedColor;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: AppColors.textPrimary, width: 2.5)
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50)),
            child: const Text('Salvar serviço'),
          ),
        ],
      ),
    );
  }
}

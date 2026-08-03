import 'package:flutter/material.dart';

import 'package:esmalte/core/di/service_locator.dart';
import 'package:esmalte/core/utils/formatters.dart';
import 'package:esmalte/models/service.dart';
import 'package:esmalte/presenters/service_list_presenter.dart';
import 'package:esmalte/views/services/service_form_screen.dart';
import 'package:esmalte/widgets/app_card.dart';
import 'package:esmalte/widgets/empty_state.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen>
    implements ServiceListView {
  late final ServiceListPresenter _presenter;
  List<Service> _services = [];

  @override
  void initState() {
    super.initState();
    _presenter = ServiceListPresenterImpl(
        serviceRepository: ServiceLocator.instance.serviceRepository);
    _presenter.attachView(this);
    _presenter.loadServices();
  }

  @override
  void dispose() {
    _presenter.detachView();
    super.dispose();
  }

  @override
  void showServices(List<Service> services) =>
      setState(() => _services = services);

  Future<void> _openForm({String? serviceId}) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ServiceFormScreen(serviceId: serviceId)));
    _presenter.loadServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Serviços')),
      body: _services.isEmpty
          ? EmptyState(
              icon: Icons.spa_outlined,
              title: 'Nenhum serviço cadastrado',
              message:
                  'Cadastre os serviços que você oferece para usá-los nos agendamentos.',
              actionLabel: 'Adicionar serviço',
              onAction: () => _openForm(),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: _services.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final service = _services[index];
                return AppCard(
                  onTap: () => _openForm(serviceId: service.id),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                            color: service.color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.name,
                              style: Theme.of(context).textTheme.titleMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${service.durationMinutes} min',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        AppFormatters.currency(service.price),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

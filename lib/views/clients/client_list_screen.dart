import 'package:flutter/material.dart';

import 'package:esmalte/core/di/service_locator.dart';
import 'package:esmalte/models/client.dart';
import 'package:esmalte/presenters/client_list_presenter.dart';
import 'package:esmalte/views/clients/client_form_screen.dart';
import 'package:esmalte/widgets/app_card.dart';
import 'package:esmalte/widgets/client_avatar.dart';
import 'package:esmalte/widgets/empty_state.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen>
    implements ClientListView {
  late final ClientListPresenter _presenter;
  final _searchController = TextEditingController();

  List<Client> _clients = [];
  bool _isEmpty = false;

  @override
  void initState() {
    super.initState();
    _presenter = ClientListPresenterImpl(
        clientRepository: ServiceLocator.instance.clientRepository);
    _presenter.attachView(this);
    _presenter.loadClients();
  }

  @override
  void dispose() {
    _presenter.detachView();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void showClients(List<Client> clients) {
    setState(() {
      _clients = clients;
      _isEmpty = false;
    });
  }

  @override
  void showEmpty() {
    setState(() {
      _clients = [];
      _isEmpty = true;
    });
  }

  Future<void> _openForm({String? clientId}) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ClientFormScreen(clientId: clientId)));
    _presenter.loadClients();
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = _searchController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _presenter.search(value);
                setState(() {});
              },
              decoration: const InputDecoration(
                hintText: 'Buscar por nome ou telefone',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _isEmpty
                ? EmptyState(
                    icon: Icons.people_outline,
                    title: isSearching
                        ? 'Nenhum resultado'
                        : 'Nenhuma cliente cadastrada',
                    message: isSearching
                        ? 'Tente buscar por outro nome ou telefone.'
                        : 'Toque no botão abaixo para cadastrar a primeira cliente.',
                    actionLabel: isSearching ? null : 'Adicionar cliente',
                    onAction: isSearching ? null : () => _openForm(),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    itemCount: _clients.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final client = _clients[index];
                      return AppCard(
                        onTap: () => _openForm(clientId: client.id),
                        child: Row(
                          children: [
                            ClientAvatar(name: client.name),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    client.name,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    client.phone,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

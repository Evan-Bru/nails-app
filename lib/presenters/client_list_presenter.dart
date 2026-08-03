import 'package:esmalte/data/repositories/client_repository.dart';
import 'package:esmalte/models/client.dart';

abstract class ClientListView {
  void showClients(List<Client> clients);
  void showEmpty();
}

abstract class ClientListPresenter {
  void attachView(ClientListView view);
  void detachView();
  void loadClients();
  void search(String query);
  void deleteClient(String id);
}

class ClientListPresenterImpl implements ClientListPresenter {
  ClientListPresenterImpl({required ClientRepository clientRepository})
      : _clientRepository = clientRepository;

  final ClientRepository _clientRepository;
  ClientListView? _view;

  @override
  void attachView(ClientListView view) => _view = view;

  @override
  void detachView() => _view = null;

  @override
  void loadClients() => _emit(_clientRepository.getAll());

  @override
  void search(String query) => _emit(_clientRepository.search(query));

  @override
  void deleteClient(String id) {
    _clientRepository.delete(id);
    loadClients();
  }

  void _emit(List<Client> clients) {
    if (clients.isEmpty) {
      _view?.showEmpty();
    } else {
      _view?.showClients(clients);
    }
  }
}

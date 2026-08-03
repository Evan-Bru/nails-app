import 'package:esmalte/data/repositories/client_repository.dart';
import 'package:esmalte/models/client.dart';
import 'package:esmalte/presenters/client_list_presenter.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeClientListView implements ClientListView {
  List<Client>? clients;
  bool emptyShown = false;

  @override
  void showClients(List<Client> clients) {
    this.clients = clients;
    emptyShown = false;
  }

  @override
  void showEmpty() {
    clients = null;
    emptyShown = true;
  }
}

void main() {
  group('ClientListPresenter', () {
    late InMemoryClientRepository clientRepository;
    late ClientListPresenterImpl presenter;
    late _FakeClientListView view;

    setUp(() {
      clientRepository = InMemoryClientRepository();
      presenter = ClientListPresenterImpl(clientRepository: clientRepository);
      view = _FakeClientListView();
      presenter.attachView(view);
    });

    test('loadClients mostra todos os clientes de exemplo', () {
      presenter.loadClients();

      expect(view.emptyShown, isFalse);
      expect(view.clients, hasLength(7));
    });

    test('search filtra pelo nome', () {
      presenter.search('camila');

      expect(view.emptyShown, isFalse);
      expect(view.clients, hasLength(1));
      expect(view.clients!.first.name, 'Camila Ferreira');
    });

    test('search sem resultado dispara showEmpty', () {
      presenter.search('inexistente');

      expect(view.emptyShown, isTrue);
      expect(view.clients, isNull);
    });

    test('deleteClient remove e reemite a lista', () {
      presenter.deleteClient('c1');

      expect(view.clients, hasLength(6));
      expect(
        view.clients!.map((c) => c.id),
        isNot(contains('c1')),
      );
    });
  });
}

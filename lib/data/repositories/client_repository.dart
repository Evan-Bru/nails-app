import 'package:esmalte/models/client.dart';

/// Contrato de acesso a dados de clientes.
///
/// Hoje só existe [InMemoryClientRepository]. No futuro, uma
/// `SqliteClientRepository` (por exemplo) pode implementar o mesmo
/// contrato sem que Presenters ou Views precisem mudar uma linha.
abstract class ClientRepository {
  List<Client> getAll();
  Client? getById(String id);
  List<Client> search(String query);
  void add(Client client);
  void update(Client client);
  void delete(String id);
}

class InMemoryClientRepository implements ClientRepository {
  final List<Client> _clients = [];

  InMemoryClientRepository() {
    _seed();
  }

  void _seed() {
    final now = DateTime.now();
    _clients.addAll([
      Client(
        id: 'c1',
        name: 'Camila Ferreira',
        phone: '(71) 99123-4501',
        birthday: DateTime(now.year, 3, 12),
        createdAt: now,
      ),
      Client(
        id: 'c2',
        name: 'Juliana Santos',
        phone: '(71) 99123-4502',
        birthday: DateTime(now.year, 7, 22),
        notes: 'Prefere esmaltação em gel',
        createdAt: now,
      ),
      Client(
        id: 'c3',
        name: 'Beatriz Almeida',
        phone: '(71) 99123-4503',
        createdAt: now,
      ),
      Client(
        id: 'c4',
        name: 'Larissa Costa',
        phone: '(71) 99123-4504',
        notes: 'Sensibilidade a removedor com acetona',
        createdAt: now,
      ),
      Client(
        id: 'c5',
        name: 'Fernanda Lima',
        phone: '(71) 99123-4505',
        createdAt: now,
      ),
      Client(
        id: 'c6',
        name: 'Patrícia Souza',
        phone: '(71) 99123-4506',
        createdAt: now,
      ),
      Client(
        id: 'c7',
        name: 'Rafaela Oliveira',
        phone: '(71) 99123-4507',
        createdAt: now,
      ),
    ]);
  }

  @override
  List<Client> getAll() {
    final list = List<Client>.from(_clients);
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  @override
  Client? getById(String id) {
    for (final client in _clients) {
      if (client.id == id) return client;
    }
    return null;
  }

  @override
  List<Client> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return getAll();
    return getAll()
        .where((c) => c.name.toLowerCase().contains(q) || c.phone.contains(q))
        .toList();
  }

  @override
  void add(Client client) => _clients.add(client);

  @override
  void update(Client client) {
    final index = _clients.indexWhere((c) => c.id == client.id);
    if (index != -1) _clients[index] = client;
  }

  @override
  void delete(String id) => _clients.removeWhere((c) => c.id == id);
}

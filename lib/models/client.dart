/// Representa uma cliente cadastrada no salão.
///
/// É um objeto imutável: qualquer alteração deve ser feita via [copyWith],
/// que retorna uma nova instância. Isso evita efeitos colaterais
/// inesperados entre a camada de dados e a camada de apresentação.
class Client {
  final String id;
  final String name;
  final String phone;
  final DateTime? birthday;
  final String? notes;
  final DateTime createdAt;

  const Client({
    required this.id,
    required this.name,
    required this.phone,
    this.birthday,
    this.notes,
    required this.createdAt,
  });

  Client copyWith({
    String? name,
    String? phone,
    DateTime? birthday,
    bool clearBirthday = false,
    String? notes,
    bool clearNotes = false,
  }) {
    return Client(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      birthday: clearBirthday ? null : (birthday ?? this.birthday),
      notes: clearNotes ? null : (notes ?? this.notes),
      createdAt: createdAt,
    );
  }
}

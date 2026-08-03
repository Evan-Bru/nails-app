/// Formatadores de data, hora e moeda em pt-BR, escritos à mão para não
/// depender do pacote `intl` (e da inicialização de locale que ele exige)
/// só para um punhado de formatações simples.
class AppFormatters {
  AppFormatters._();

  static const _weekdaysFull = [
    'Domingo',
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
  ];

  static const _weekdaysShort = [
    'DOM',
    'SEG',
    'TER',
    'QUA',
    'QUI',
    'SEX',
    'SÁB',
  ];

  static const _months = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];

  // DateTime.weekday: 1=segunda ... 7=domingo. `% 7` alinha domingo (7) ao
  // índice 0 das listas acima, que começam em domingo.
  static String weekdayName(DateTime date) => _weekdaysFull[date.weekday % 7];

  static String weekdayShort(DateTime date) => _weekdaysShort[date.weekday % 7];

  static String monthName(DateTime date) => _months[date.month - 1];

  static String time(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  static String shortDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';

  static String fullDate(DateTime date) =>
      '${date.day} de ${monthName(date)} de ${date.year}';

  /// Formata como "R$ 1.234,56".
  static String currency(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final intPart = parts[0].replaceFirst('-', '');
    final decPart = parts[1];

    final buffer = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write('.');
      buffer.write(intPart[i]);
    }

    final sign = value < 0 ? '-' : '';
    return '${sign}R\$ ${buffer.toString()},$decPart';
  }
}

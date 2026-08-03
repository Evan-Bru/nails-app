import 'package:esmalte/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppFormatters.currency', () {
    test('formata com separador de milhar e duas casas', () {
      expect(AppFormatters.currency(1234.56), r'R$ 1.234,56');
      expect(AppFormatters.currency(1000000), r'R$ 1.000.000,00');
    });

    test('formata zero e valores pequenos', () {
      expect(AppFormatters.currency(0), r'R$ 0,00');
      expect(AppFormatters.currency(35), r'R$ 35,00');
    });

    test('mantém o sinal negativo antes do símbolo', () {
      expect(AppFormatters.currency(-5.5), r'-R$ 5,50');
    });
  });

  group('AppFormatters datas', () {
    // 01/01/2024 foi uma segunda-feira; 07/01/2024, um domingo.
    final monday = DateTime(2024, 1, 1, 9, 5);
    final sunday = DateTime(2024, 1, 7);

    test('weekdayName cobre segunda e domingo', () {
      expect(AppFormatters.weekdayName(monday), 'Segunda-feira');
      expect(AppFormatters.weekdayName(sunday), 'Domingo');
    });

    test('weekdayShort devolve a abreviação', () {
      expect(AppFormatters.weekdayShort(monday), 'SEG');
      expect(AppFormatters.weekdayShort(sunday), 'DOM');
    });

    test('time preenche com zero à esquerda', () {
      expect(AppFormatters.time(monday), '09:05');
    });

    test('shortDate usa dd/MM', () {
      expect(AppFormatters.shortDate(DateTime(2024, 3, 7)), '07/03');
    });

    test('monthName e fullDate em pt-BR', () {
      expect(AppFormatters.monthName(DateTime(2024, 3, 15)), 'março');
      expect(
          AppFormatters.fullDate(DateTime(2024, 3, 15)), '15 de março de 2024');
    });
  });
}

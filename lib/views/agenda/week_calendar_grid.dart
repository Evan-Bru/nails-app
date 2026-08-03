import 'package:flutter/material.dart';

import 'package:esmalte/models/appointment_details.dart';
import 'package:esmalte/views/agenda/agenda_grid_config.dart';
import 'package:esmalte/views/agenda/day_column.dart';
import 'package:esmalte/views/agenda/time_axis.dart';

/// Grade semanal da agenda.
///
/// Em telas estreitas (celular / janela pequena) a semana inteira não cabe, e
/// aí as colunas dos dias ficam com a largura mínima e a grade passa a rolar na
/// horizontal. Deixo a **rolagem horizontal por fora** (com barra fixa no
/// rodapé, sempre visível quando há o que rolar) e a **vertical por dentro** —
/// assim dá pra ver e alcançar as datas laterais sem a barra sumir no fim do
/// conteúdo.
class WeekCalendarGrid extends StatefulWidget {
  const WeekCalendarGrid({
    super.key,
    required this.workingDays,
    required this.appointments,
    required this.onSlotTap,
    required this.onAppointmentTap,
  });

  final List<DateTime> workingDays;
  final List<AppointmentDetails> appointments;
  final void Function(DateTime day, DateTime time) onSlotTap;
  final void Function(AppointmentDetails details) onAppointmentTap;

  @override
  State<WeekCalendarGrid> createState() => _WeekCalendarGridState();
}

class _WeekCalendarGridState extends State<WeekCalendarGrid> {
  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  List<AppointmentDetails> _appointmentsForDay(DateTime day) {
    return widget.appointments.where((a) {
      final d = a.start;
      return d.year == day.year && d.month == day.month && d.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = widget.workingDays;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth =
            constraints.maxWidth - AgendaGridConfig.timeColumnWidth;
        final perColumn = days.isEmpty ? availableWidth : availableWidth / days.length;
        final dayColumnWidth =
            perColumn.clamp(AgendaGridConfig.dayColumnMinWidth, double.infinity);

        final totalWidth = AgendaGridConfig.totalWidthFor(
          days.length,
          dayColumnWidth: dayColumnWidth,
        );

        final needsHorizontalScroll = totalWidth > constraints.maxWidth + 0.5;

        final row = SizedBox(
          width: totalWidth,
          height: AgendaGridConfig.totalHeightWithHeader,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TimeAxis(),
              ...days.map((day) {
                final isToday = day.year == today.year &&
                    day.month == today.month &&
                    day.day == today.day;
                return DayColumn(
                  day: day,
                  isToday: isToday,
                  appointments: _appointmentsForDay(day),
                  onSlotTap: (time) => widget.onSlotTap(day, time),
                  onAppointmentTap: widget.onAppointmentTap,
                  columnWidth: dayColumnWidth,
                );
              }),
            ],
          ),
        );

        // Camada vertical (interna): rola a grade de horários dentro da altura
        // da tela.
        final verticalScroller = SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: row,
        );

        if (!needsHorizontalScroll) {
          return verticalScroller;
        }

        // Camada horizontal (externa): quando a semana não cabe, rola os dias
        // de lado. A barra fica fixa no rodapé da tela, então o usuário vê que
        // dá pra ir para as datas ao lado.
        return Scrollbar(
          controller: _horizontalController,
          thumbVisibility: true,
          scrollbarOrientation: ScrollbarOrientation.bottom,
          child: SingleChildScrollView(
            controller: _horizontalController,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: totalWidth,
              child: verticalScroller,
            ),
          ),
        );
      },
    );
  }
}

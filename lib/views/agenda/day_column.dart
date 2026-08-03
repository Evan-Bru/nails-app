import 'package:flutter/material.dart';

import 'package:esmalte/core/theme/app_colors.dart';
import 'package:esmalte/core/utils/formatters.dart';
import 'package:esmalte/models/appointment_details.dart';
import 'package:esmalte/views/agenda/agenda_grid_config.dart';
import 'package:esmalte/views/agenda/appointment_block.dart';
import 'package:esmalte/views/agenda/grid_lines.dart';

class DayColumn extends StatelessWidget {
  const DayColumn({
    super.key,
    required this.day,
    required this.isToday,
    required this.appointments,
    required this.onSlotTap,
    required this.onAppointmentTap,
    required this.columnWidth,
  });

  final DateTime day;
  final bool isToday;
  final List<AppointmentDetails> appointments;
  final void Function(DateTime time) onSlotTap;
  final void Function(AppointmentDetails) onAppointmentTap;
  final double columnWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DayHeader(day: day, isToday: isToday, width: columnWidth),
        SizedBox(
          width: columnWidth,
          height: AgendaGridConfig.totalHeight,
          child: Stack(
            children: [
              const Positioned.fill(child: GridLines()),
              ..._buildTapTargets(),
              ...appointments.map((a) => AppointmentBlock(
                    details: a,
                    onTap: () => onAppointmentTap(a),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTapTargets() {
    final targets = <Widget>[];
    const totalMinutes =
        (AgendaGridConfig.endHour - AgendaGridConfig.startHour) * 60;
    for (var m = 0; m < totalMinutes; m += 30) {
      final time =
          DateTime(day.year, day.month, day.day, AgendaGridConfig.startHour)
              .add(Duration(minutes: m));
      targets.add(Positioned(
        top: (m / AgendaGridConfig.slotMinutes) * AgendaGridConfig.slotHeight,
        left: 0,
        right: 0,
        height:
            (30 / AgendaGridConfig.slotMinutes) * AgendaGridConfig.slotHeight,
        child: Material(
          color: Colors.transparent,
          child: InkWell(onTap: () => onSlotTap(time)),
        ),
      ));
    }
    return targets;
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader(
      {required this.day, required this.isToday, required this.width});

  final DateTime day;
  final bool isToday;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: AgendaGridConfig.headerHeight,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isToday ? AppColors.primary.withAlpha(20) : Colors.transparent,
        border: const Border(left: BorderSide(color: AppColors.surfaceMuted)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppFormatters.weekdayShort(day),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isToday ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isToday ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

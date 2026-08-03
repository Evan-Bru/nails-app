import 'package:flutter/material.dart';

import 'package:esmalte/core/theme/app_colors.dart';
import 'package:esmalte/views/agenda/agenda_grid_config.dart';

class TimeAxis extends StatelessWidget {
  const TimeAxis({super.key});

  @override
  Widget build(BuildContext context) {
    final hours = <Widget>[];
    hours.add(const SizedBox(height: AgendaGridConfig.headerHeight));

    for (var h = AgendaGridConfig.startHour;
        h < AgendaGridConfig.endHour;
        h++) {
      hours.add(SizedBox(
        height: AgendaGridConfig.hourHeight,
        width: AgendaGridConfig.timeColumnWidth,
        child: Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 8, top: 2),
            child: Text(
              '${h.toString().padLeft(2, '0')}:00',
              style:
                  const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ),
        ),
      ));
    }
    return Column(mainAxisSize: MainAxisSize.min, children: hours);
  }
}

import 'package:flutter/material.dart';

import 'package:esmalte/core/theme/app_colors.dart';
import 'package:esmalte/views/agenda/agenda_grid_config.dart';

class GridLines extends StatelessWidget {
  const GridLines({super.key});

  @override
  Widget build(BuildContext context) {
    const hourCount = AgendaGridConfig.endHour - AgendaGridConfig.startHour;
    return Stack(
      children: List.generate(hourCount + 1, (h) {
        return Positioned(
          top: h * AgendaGridConfig.hourHeight,
          left: 0,
          right: 0,
          child: Container(height: 1, color: AppColors.surfaceMuted),
        );
      }),
    );
  }
}

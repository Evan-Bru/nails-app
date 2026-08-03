import 'package:flutter/material.dart';

import 'package:esmalte/core/theme/app_colors.dart';
import 'package:esmalte/core/utils/formatters.dart';
import 'package:esmalte/models/appointment.dart';
import 'package:esmalte/models/appointment_details.dart';
import 'package:esmalte/views/agenda/agenda_grid_config.dart';

class AppointmentBlock extends StatelessWidget {
  const AppointmentBlock(
      {super.key, required this.details, required this.onTap});

  final AppointmentDetails details;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final top = AgendaGridConfig.offsetForTime(details.start);
    final rawHeight = AgendaGridConfig.heightForDuration(
      details.service?.durationMinutes ?? 30,
    );
    final height = rawHeight < 24 ? 24.0 : rawHeight - 2;
    final color = details.service?.color ?? AppColors.primary;
    final isCancelled =
        details.appointment.status == AppointmentStatus.cancelled;
    final isCompact = height < 40;

    return Positioned(
      top: top + 1,
      left: 4,
      right: 4,
      height: height,
      child: GestureDetector(
        onTap: onTap,
        child: Opacity(
          opacity: isCancelled ? 0.45 : 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withAlpha(41),
              border: Border(left: BorderSide(color: color, width: 3)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: isCompact
                ? _compactContent(isCancelled)
                : _fullContent(isCancelled),
          ),
        ),
      ),
    );
  }

  Widget _compactContent(bool isCancelled) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        '${AppFormatters.time(details.start)} · ${details.clientName}',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          decoration: isCancelled ? TextDecoration.lineThrough : null,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _fullContent(bool isCancelled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            '${AppFormatters.time(details.start)} · ${details.clientName}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              decoration: isCancelled ? TextDecoration.lineThrough : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Flexible(
          child: Text(
            details.serviceName,
            style:
                const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

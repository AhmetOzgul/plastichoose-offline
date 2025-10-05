import 'package:flutter/material.dart';
import 'package:plastichoose/features/cleanup/presentation/controllers/cleanup_controller.dart';

final class CleanupDateSelector extends StatelessWidget {
  final CleanupController controller;
  const CleanupDateSelector({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final DateTime now = DateTime.now();
              final DateTimeRange? range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(now.year - 5),
                lastDate: DateTime(now.year + 1),
                initialDateRange: DateTimeRange(
                  start: now.subtract(const Duration(days: 30)),
                  end: now,
                ),
              );
              controller.setRange(range);
              await controller.refreshPreview();
            },
            icon: const Icon(Icons.date_range),
            label: Text(controller.getDateRangeText()),
          ),
        ),
      ],
    );
  }
}

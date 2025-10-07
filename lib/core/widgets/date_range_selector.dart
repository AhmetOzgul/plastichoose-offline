import 'package:flutter/material.dart';
import 'package:plastichoose/core/utils/date_range_utils.dart';

/// Shared date range selector that normalizes the selected range to be
/// inclusive for the end date (until 23:59:59.999).
final class DateRangeSelector extends StatelessWidget {
  final String label;
  final DateTimeRange? value;
  final ValueChanged<DateTimeRange?> onChanged;

  const DateRangeSelector({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final DateTime now = DateTime.now();
              final DateTimeRange initial =
                  value ??
                  DateTimeRange(
                    start: now.subtract(const Duration(days: 30)),
                    end: now,
                  );
              final DateTimeRange? picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(now.year - 5),
                lastDate: DateTime(now.year + 1),
                initialDateRange: DateTimeRange(
                  start: initial.start,
                  end: initial.end,
                ),
              );
              onChanged(DateRangeUtils.normalizeInclusive(picked));
            },
            icon: const Icon(Icons.date_range),
            label: Text(_labelText()),
          ),
        ),
      ],
    );
  }

  String _labelText() {
    if (value == null) return label;
    final DateTime s = value!.start;
    final DateTime e = value!.end;
    return '${_two(s.day)}.${_two(s.month)}.${s.year} - '
        '${_two(e.day)}.${_two(e.month)}.${e.year}';
  }

  String _two(int v) => v.toString().padLeft(2, '0');
}

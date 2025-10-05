import 'package:flutter/material.dart';
import 'package:plastichoose/features/patients/domain/entities/decision_status.dart';

final class PatientStatusChip extends StatelessWidget {
  final DecisionStatus status;

  const PatientStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color chipColor;
    Color textColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case DecisionStatus.accepted:
        chipColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        statusText = 'Kabul Edildi';
        statusIcon = Icons.check_circle;
        break;
      case DecisionStatus.rejected:
        chipColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
        statusText = 'Reddedildi';
        statusIcon = Icons.cancel;
        break;
      case DecisionStatus.none:
        chipColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        statusText = 'Bekliyor';
        statusIcon = Icons.visibility;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(statusIcon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

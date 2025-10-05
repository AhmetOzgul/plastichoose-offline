import 'package:flutter/material.dart';
import 'package:plastichoose/features/patients/domain/entities/patient.dart';
import 'package:plastichoose/features/patients/domain/entities/decision_status.dart';

final class StatusChangeDialog extends StatelessWidget {
  final Patient patient;
  final Function(String patientId, DecisionStatus status) onStatusChanged;

  const StatusChangeDialog({
    super.key,
    required this.patient,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Durum Değiştir - ${patient.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: DecisionStatus.values.map((status) {
          return ListTile(
            leading: Icon(
              _getStatusIcon(status),
              color: _getStatusColor(status),
            ),
            title: Text(_getStatusText(status)),
            trailing: patient.decisionStatus == status
                ? Icon(Icons.check, color: Colors.green.shade600)
                : null,
            onTap: () {
              Navigator.of(context).pop();
              onStatusChanged(patient.id, status);
            },
          );
        }).toList(),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
      ],
    );
  }

  Color _getStatusColor(DecisionStatus status) {
    switch (status) {
      case DecisionStatus.accepted:
        return Colors.green.shade700;
      case DecisionStatus.rejected:
        return Colors.red.shade700;
      case DecisionStatus.none:
        return Colors.orange.shade700;
    }
  }

  String _getStatusText(DecisionStatus status) {
    switch (status) {
      case DecisionStatus.accepted:
        return 'Kabul Edildi';
      case DecisionStatus.rejected:
        return 'Reddedildi';
      case DecisionStatus.none:
        return 'Bekliyor';
    }
  }

  IconData _getStatusIcon(DecisionStatus status) {
    switch (status) {
      case DecisionStatus.accepted:
        return Icons.check_circle;
      case DecisionStatus.rejected:
        return Icons.cancel;
      case DecisionStatus.none:
        return Icons.visibility;
    }
  }
}

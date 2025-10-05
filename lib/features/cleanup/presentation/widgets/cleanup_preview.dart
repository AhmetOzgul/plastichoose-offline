import 'package:flutter/material.dart';
import 'package:plastichoose/features/cleanup/presentation/controllers/cleanup_controller.dart';

final class CleanupPreview extends StatelessWidget {
  final CleanupController controller;
  const CleanupPreview({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.delete_forever, color: Colors.red.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${controller.selectedPatientsCount} hasta silinecek',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

final class CleanupActions extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onDelete;
  const CleanupActions({
    super.key,
    required this.isEnabled,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isEnabled ? onDelete : null,
            icon: const Icon(Icons.delete_rounded),
            label: const Text('Seçili Hastaları Sil'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

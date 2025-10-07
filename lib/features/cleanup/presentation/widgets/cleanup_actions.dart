import 'package:flutter/material.dart';
import 'package:plastichoose/core/widgets/gradient_button.dart';

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
    final List<Color> colors = isEnabled
        ? <Color>[Colors.red.shade600, Colors.red.shade400]
        : <Color>[Colors.red.shade200, Colors.red.shade100];
    return Row(
      children: <Widget>[
        Expanded(
          child: GradientButton(
            colors: colors,
            onPressed: isEnabled ? onDelete : null,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.delete_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Seçili Hastaları Sil',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

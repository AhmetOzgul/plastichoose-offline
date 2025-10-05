import 'package:flutter/material.dart';
import 'package:plastichoose/features/cleanup/presentation/controllers/cleanup_controller.dart';

final class CleanupOptions extends StatelessWidget {
  final CleanupController controller;
  const CleanupOptions({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SwitchTile(
          title: 'Karar verilmemiş hastalar',
          value: controller.includeUndecided,
          onChanged: (bool v) => controller.toggleOption(undecided: v),
        ),
        _SwitchTile(
          title: 'Kabul edilen hastalar',
          value: controller.includeAccepted,
          onChanged: (bool v) => controller.toggleOption(accepted: v),
        ),
        _SwitchTile(
          title: 'Reddedilen hastalar',
          value: controller.includeRejected,
          onChanged: (bool v) => controller.toggleOption(rejected: v),
        ),
      ],
    );
  }
}

final class _SwitchTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(title)),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

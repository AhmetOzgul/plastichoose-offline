import 'package:flutter/material.dart';

final class ReviewCardActions extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onSkip;

  const ReviewCardActions({
    super.key,
    required this.onAccept,
    required this.onReject,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _ModernActionButton(
              icon: Icons.close,
              label: 'Reddet',
              color: Colors.red,
              onTap: onReject,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _ModernActionButton(
              icon: Icons.skip_next,
              label: 'Atla',
              color: Colors.orange,
              onTap: onSkip,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _ModernActionButton(
              icon: Icons.check,
              label: 'Kabul Et',
              color: Colors.green,
              onTap: onAccept,
            ),
          ),
        ],
      ),
    );
  }
}

final class _ModernActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ModernActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[color, color.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

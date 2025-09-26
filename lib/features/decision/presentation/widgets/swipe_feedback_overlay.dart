import 'package:flutter/material.dart';

final class SwipeFeedbackOverlay extends StatelessWidget {
  final String direction;
  final double dragOffset;

  const SwipeFeedbackOverlay({
    super.key,
    required this.direction,
    required this.dragOffset,
  });

  @override
  Widget build(BuildContext context) {
    final bool isReject = direction == 'left';
    final double opacity = (dragOffset.abs() / 100).clamp(0.0, 1.0);

    return Positioned.fill(
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: (isReject ? Colors.red : Colors.green).withOpacity(
            opacity * 0.2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: (isReject ? Colors.red : Colors.green).withOpacity(
                    opacity,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isReject ? Icons.close : Icons.check,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isReject ? 'REDDET' : 'KABUL ET',
                style: TextStyle(
                  color: (isReject ? Colors.red : Colors.green).withOpacity(
                    opacity,
                  ),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

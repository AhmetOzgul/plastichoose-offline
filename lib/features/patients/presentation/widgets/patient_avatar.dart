import 'dart:io';
import 'package:flutter/material.dart';
import 'package:plastichoose/features/patients/domain/entities/patient.dart';

final class PatientAvatar extends StatelessWidget {
  final Patient patient;
  final Color tertiary;

  const PatientAvatar({
    super.key,
    required this.patient,
    required this.tertiary,
  });

  @override
  Widget build(BuildContext context) {
    if (patient.images.isNotEmpty) {
      final imageIndex = patient.images.length >= 2 ? 1 : 0;
      final imagePath = patient.images[imageIndex];
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            File(imagePath),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: tertiary.withOpacity(0.1),
              child: Icon(Icons.person, color: tertiary, size: 24),
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: tertiary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tertiary.withOpacity(0.2), width: 1),
        ),
        child: Icon(Icons.person, color: tertiary, size: 28),
      );
    }
  }
}

import 'package:plastichoose/features/patients/domain/entities/decision_status.dart';

/// Patient domain entity.
final class Patient {
  final String id;
  final String name;
  final List<String> images;
  final DecisionStatus decisionStatus;
  final DateTime? decisionAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Patient({
    required this.id,
    required this.name,
    required this.images,
    required this.decisionStatus,
    required this.decisionAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Patient copyWith({
    String? id,
    String? name,
    List<String>? images,
    DecisionStatus? decisionStatus,
    DateTime? decisionAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      images: images ?? this.images,
      decisionStatus: decisionStatus ?? this.decisionStatus,
      decisionAt: decisionAt ?? this.decisionAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

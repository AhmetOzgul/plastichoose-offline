import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:plastichoose/features/patients/domain/entities/decision_status.dart';

part 'patient.freezed.dart';
part 'patient.g.dart';

/// Patient domain entity.
@freezed
class Patient with _$Patient {
  const factory Patient({
    required String id,
    required String name,
    required List<String> images,
    @Default(DecisionStatus.none) DecisionStatus decisionStatus,
    DateTime? decisionAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Patient;

  factory Patient.fromJson(Map<String, dynamic> json) =>
      _$PatientFromJson(json);
}

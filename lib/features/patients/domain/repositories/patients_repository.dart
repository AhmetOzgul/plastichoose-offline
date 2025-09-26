import 'package:plastichoose/core/result/result.dart';
import 'package:plastichoose/features/patients/domain/entities/decision_status.dart';
import 'package:plastichoose/features/patients/domain/entities/patient.dart';

/// Repository contract for patient persistence and queries.
abstract interface class PatientsRepository {
  Future<Result<Patient>> addPatient({
    required String name,
    required List<String> imagePaths,
  });

  Future<Result<void>> deletePatient({required String patientId});

  Future<Result<Patient>> updatePatient({required Patient patient});

  Future<Result<List<Patient>>> listPatients({
    String? nameQuery,
    DecisionStatus? status,
  });

  Future<Result<Patient>> getPatient({required String patientId});

  Future<Result<Patient>> decidePatient({
    required String patientId,
    required DecisionStatus decision,
    required DateTime decidedAt,
  });

  Future<Result<Patient>> undoDecision({required String patientId});
}

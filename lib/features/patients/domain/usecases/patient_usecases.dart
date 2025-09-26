import 'package:plastichoose/core/result/result.dart';
import 'package:plastichoose/features/patients/domain/entities/decision_status.dart';
import 'package:plastichoose/features/patients/domain/entities/patient.dart';
import 'package:plastichoose/features/patients/domain/repositories/patients_repository.dart';
import 'package:plastichoose/features/patients/domain/usecases/use_case.dart';

final class AddPatientParams {
  final String name;
  final List<String> imagePaths;
  const AddPatientParams({required this.name, required this.imagePaths});
}

final class AddPatient implements UseCase<Patient, AddPatientParams> {
  final PatientsRepository repository;
  const AddPatient(this.repository);
  @override
  Future<Result<Patient>> execute(AddPatientParams params) =>
      repository.addPatient(name: params.name, imagePaths: params.imagePaths);
}

final class DeletePatientParams {
  final String patientId;
  const DeletePatientParams({required this.patientId});
}

final class DeletePatient implements UseCase<void, DeletePatientParams> {
  final PatientsRepository repository;
  const DeletePatient(this.repository);
  @override
  Future<Result<void>> execute(DeletePatientParams params) =>
      repository.deletePatient(patientId: params.patientId);
}

final class UpdatePatientParams {
  final Patient patient;
  const UpdatePatientParams({required this.patient});
}

final class UpdatePatient implements UseCase<Patient, UpdatePatientParams> {
  final PatientsRepository repository;
  const UpdatePatient(this.repository);
  @override
  Future<Result<Patient>> execute(UpdatePatientParams params) =>
      repository.updatePatient(patient: params.patient);
}

final class ListPatientsParams {
  final String? nameQuery;
  final DecisionStatus? status;
  const ListPatientsParams({this.nameQuery, this.status});
}

final class ListPatients implements UseCase<List<Patient>, ListPatientsParams> {
  final PatientsRepository repository;
  const ListPatients(this.repository);
  @override
  Future<Result<List<Patient>>> execute(ListPatientsParams params) => repository
      .listPatients(nameQuery: params.nameQuery, status: params.status);
}

final class GetPatientParams {
  final String patientId;
  const GetPatientParams({required this.patientId});
}

final class GetPatient implements UseCase<Patient, GetPatientParams> {
  final PatientsRepository repository;
  const GetPatient(this.repository);
  @override
  Future<Result<Patient>> execute(GetPatientParams params) =>
      repository.getPatient(patientId: params.patientId);
}

final class DecidePatientParams {
  final String patientId;
  final DecisionStatus decision;
  final DateTime decidedAt;
  const DecidePatientParams({
    required this.patientId,
    required this.decision,
    required this.decidedAt,
  });
}

final class DecidePatient implements UseCase<Patient, DecidePatientParams> {
  final PatientsRepository repository;
  const DecidePatient(this.repository);
  @override
  Future<Result<Patient>> execute(DecidePatientParams params) =>
      repository.decidePatient(
        patientId: params.patientId,
        decision: params.decision,
        decidedAt: params.decidedAt,
      );
}

final class UndoDecisionParams {
  final String patientId;
  const UndoDecisionParams({required this.patientId});
}

final class UndoDecision implements UseCase<Patient, UndoDecisionParams> {
  final PatientsRepository repository;
  const UndoDecision(this.repository);
  @override
  Future<Result<Patient>> execute(UndoDecisionParams params) =>
      repository.undoDecision(patientId: params.patientId);
}

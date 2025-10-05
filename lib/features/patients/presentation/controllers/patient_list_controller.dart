import 'package:flutter/foundation.dart';
import 'package:plastichoose/app/di.dart';
import 'package:plastichoose/features/patients/domain/entities/patient.dart';
import 'package:plastichoose/features/patients/domain/entities/decision_status.dart';
import 'package:plastichoose/features/patients/domain/usecases/patient_usecases.dart';

final class PatientListController extends ChangeNotifier {
  bool isLoading = true;
  String? errorMessage;
  final List<Patient> _patients = <Patient>[];

  List<Patient> get patients => List<Patient>.unmodifiable(_patients);

  final ListPatients _listPatients = getIt<ListPatients>();
  final DecidePatient _decidePatient = getIt<DecidePatient>();
  final DeletePatient _deletePatient = getIt<DeletePatient>();

  Future<void> refresh() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _listPatients.execute(const ListPatientsParams());

      result.when(
        ok: (patients) {
          _patients.clear();
          _patients.addAll(patients);
          isLoading = false;
          notifyListeners();
        },
        err: (failure) {
          errorMessage = failure.message;
          isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      isLoading = false;
      errorMessage = 'Liste yüklenemedi: $e';
      notifyListeners();
    }
  }

  Future<void> changePatientStatus(
    String patientId,
    DecisionStatus newStatus,
  ) async {
    try {
      final result = await _decidePatient.execute(
        DecidePatientParams(
          patientId: patientId,
          decision: newStatus,
          decidedAt: DateTime.now(),
        ),
      );

      result.when(
        ok: (updatedPatient) {
          // Update the patient in the list
          final index = _patients.indexWhere((p) => p.id == patientId);
          if (index != -1) {
            _patients[index] = updatedPatient;
            notifyListeners();
          }
        },
        err: (failure) {
          errorMessage = failure.message;
          notifyListeners();
        },
      );
    } catch (e) {
      errorMessage = 'Durum değiştirilirken hata oluştu: $e';
      notifyListeners();
    }
  }

  Future<void> deletePatient(String patientId) async {
    try {
      final result = await _deletePatient.execute(
        DeletePatientParams(patientId: patientId),
      );

      result.when(
        ok: (_) {
          // Remove patient from the list
          _patients.removeWhere((p) => p.id == patientId);
          notifyListeners();
        },
        err: (failure) {
          errorMessage = failure.message;
          notifyListeners();
        },
      );
    } catch (e) {
      errorMessage = 'Hasta silinirken hata oluştu: $e';
      notifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}

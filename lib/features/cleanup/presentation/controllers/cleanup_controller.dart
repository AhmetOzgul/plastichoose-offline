import 'package:flutter/material.dart';
import 'package:plastichoose/core/result/result.dart';
import 'package:plastichoose/features/patients/domain/entities/decision_status.dart';
import 'package:plastichoose/features/patients/domain/entities/patient.dart';
import 'package:plastichoose/features/patients/domain/usecases/patient_usecases.dart';

/// Controls cleanup operations: filtering and deleting patients in bulk.
final class CleanupController extends ChangeNotifier {
  final ListPatients _listPatients;
  final DeletePatient _deletePatient;

  CleanupController({
    required ListPatients listPatients,
    required DeletePatient deletePatient,
  }) : _listPatients = listPatients,
       _deletePatient = deletePatient;

  DateTimeRange? _range;
  bool includeUndecided = true;
  bool includeAccepted = false;
  bool includeRejected = false;

  int selectedPatientsCount = 0;
  bool isLoading = false;
  String? errorMessage;

  DateTimeRange? get range => _range;

  /// Sets the date range for filtering.
  void setRange(DateTimeRange? range) {
    _range = range;
    notifyListeners();
  }

  /// Returns a human-readable date range text.
  String getDateRangeText() {
    if (_range == null) return 'Tümü';
    final DateTime start = _range!.start;
    final DateTime end = _range!.end;
    return '${start.day}.${start.month}.${start.year} - ${end.day}.${end.month}.${end.year}';
  }

  /// Toggles an option and refreshes preview count.
  Future<void> toggleOption({
    bool? undecided,
    bool? accepted,
    bool? rejected,
  }) async {
    if (undecided != null) includeUndecided = undecided;
    if (accepted != null) includeAccepted = accepted;
    if (rejected != null) includeRejected = rejected;
    await refreshPreview();
  }

  /// Computes and updates the preview count of patients to delete.
  Future<void> refreshPreview() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final List<Patient> toDelete = await _collectPatientsToDelete();
      selectedPatientsCount = toDelete.length;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Önizleme hesaplanamadı';
      notifyListeners();
    }
  }

  /// Returns ids of patients to delete based on filters.
  Future<List<String>> getPatientsToDelete() async {
    final List<Patient> items = await _collectPatientsToDelete();
    return items.map((Patient p) => p.id).toList(growable: false);
  }

  Future<List<Patient>> _collectPatientsToDelete() async {
    final List<DecisionStatus> statuses = <DecisionStatus>[
      if (includeUndecided) DecisionStatus.none,
      if (includeAccepted) DecisionStatus.accepted,
      if (includeRejected) DecisionStatus.rejected,
    ];
    final List<Patient> aggregated = <Patient>[];
    for (final DecisionStatus s in statuses) {
      final Result<List<Patient>> res = await _listPatients.execute(
        ListPatientsParams(status: s),
      );
      res.when(
        ok: (List<Patient> list) => aggregated.addAll(list),
        err: (_) {},
      );
    }
    return aggregated
        .where((Patient p) {
          if (_range == null) return true;
          final DateTime d = p.createdAt;
          return !d.isBefore(_range!.start) && !d.isAfter(_range!.end);
        })
        .toList(growable: false);
  }

  /// Executes deletion in bulk.
  Future<void> deleteSelected() async {
    final List<String> ids = await getPatientsToDelete();
    for (final String id in ids) {
      await _deletePatient.execute(DeletePatientParams(patientId: id));
    }
  }
}

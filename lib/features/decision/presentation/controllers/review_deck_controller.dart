import 'package:flutter/foundation.dart';
import 'package:plastichoose/core/result/result.dart';
import 'package:plastichoose/features/patients/domain/entities/patient.dart';
import 'package:plastichoose/features/patients/domain/entities/decision_status.dart';
import 'package:plastichoose/features/patients/domain/usecases/patient_usecases.dart';

/// Basit UI odaklı controller: listeyi tutar ve karar/atla aksiyonlarını yönetir.
final class ReviewDeckController extends ChangeNotifier {
  final ListPatients _listPatients;
  final DecidePatient _decidePatient;

  ReviewDeckController({
    required ListPatients listPatients,
    required DecidePatient decidePatient,
  }) : _listPatients = listPatients,
       _decidePatient = decidePatient;

  bool isLoading = true;
  String? errorMessage;
  final List<Patient> _undecided = <Patient>[];
  int _index = 0;

  List<Patient> get newPatients => List<Patient>.unmodifiable(_undecided);
  Patient? get currentPatient => _undecided.isEmpty
      ? null
      : _undecided[_index.clamp(0, _undecided.length - 1)];

  Future<void> refresh() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final Result<List<Patient>> res = await _listPatients.execute(
        const ListPatientsParams(status: DecisionStatus.none),
      );
      res.when(
        ok: (List<Patient> items) {
          _undecided
            ..clear()
            ..addAll(items);
          _index = 0;
          isLoading = false;
          notifyListeners();
        },
        err: (Failure f) {
          isLoading = false;
          errorMessage = f.message;
          notifyListeners();
        },
      );
    } catch (e) {
      isLoading = false;
      errorMessage = 'Liste yüklenemedi';
      notifyListeners();
    }
  }

  Future<void> acceptPatient(Patient patient) async {
    await _applyDecision(DecisionStatus.accepted);
  }

  Future<void> rejectPatient(Patient patient) async {
    await _applyDecision(DecisionStatus.rejected);
  }

  void skipPatient(Patient patient) {
    _next();
  }

  Future<void> _applyDecision(DecisionStatus status) async {
    if (_undecided.isEmpty) return;
    final Patient p = _undecided[_index];
    final Result<Patient> res = await _decidePatient.execute(
      DecidePatientParams(
        patientId: p.id,
        decision: status,
        decidedAt: DateTime.now(),
      ),
    );
    res.when(
      ok: (Patient _) {
        _undecided.removeAt(_index);
        if (_index >= _undecided.length) {
          _index = (_undecided.isEmpty) ? 0 : _undecided.length - 1;
        }
        notifyListeners();
      },
      err: (Failure f) {
        errorMessage = f.message;
        notifyListeners();
      },
    );
  }

  void _next() {
    if (_undecided.isEmpty) return;
    _index = (_index + 1) % _undecided.length;
    notifyListeners();
  }
}

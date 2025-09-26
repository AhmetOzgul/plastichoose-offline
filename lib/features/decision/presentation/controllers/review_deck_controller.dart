import 'package:flutter/foundation.dart';
import 'package:plastichoose/features/patients/domain/entities/patient.dart';
import 'package:plastichoose/features/patients/domain/entities/decision_status.dart';

/// Basit UI odaklı controller: listeyi tutar ve karar/atla aksiyonlarını yönetir.
final class ReviewDeckController extends ChangeNotifier {
  ReviewDeckController();

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
      // TODO: Data katmanı hazır olunca undecided hastaları yükle.
      // Şimdilik boş liste ile ilerliyoruz.
      _undecided.clear();
      _index = 0;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Liste yüklenemedi';
      notifyListeners();
    }
  }

  void acceptPatient(Patient patient) {
    _applyDecision(DecisionStatus.accepted);
  }

  void rejectPatient(Patient patient) {
    _applyDecision(DecisionStatus.rejected);
  }

  void skipPatient(Patient patient) {
    _next();
  }

  void _applyDecision(DecisionStatus status) {
    if (_undecided.isEmpty) return;
    final Patient p = _undecided[_index];
    _undecided[_index] = p.copyWith(
      decisionStatus: status,
      decisionAt: DateTime.now(),
    );
    // TODO: UseCase ile persist edilecek.
    _undecided.removeAt(_index);
    if (_index >= _undecided.length) {
      _index = (_undecided.isEmpty) ? 0 : _undecided.length - 1;
    }
    notifyListeners();
  }

  void _next() {
    if (_undecided.isEmpty) return;
    _index = (_index + 1) % _undecided.length;
    notifyListeners();
  }
}

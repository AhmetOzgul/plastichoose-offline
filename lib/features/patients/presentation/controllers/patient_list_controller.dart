import 'package:flutter/foundation.dart';
import 'package:plastichoose/features/patients/domain/entities/patient.dart';

final class PatientListController extends ChangeNotifier {
  bool isLoading = true;
  String? errorMessage;
  final List<Patient> _patients = <Patient>[];

  List<Patient> get patients => List<Patient>.unmodifiable(_patients);

  Future<void> refresh() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      // TODO: Data katmanı ile doldurulacak
      _patients.clear();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Liste yüklenemedi';
      notifyListeners();
    }
  }
}

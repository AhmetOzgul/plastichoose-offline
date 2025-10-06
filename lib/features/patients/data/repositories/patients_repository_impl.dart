import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plastichoose/core/result/result.dart';
import 'package:plastichoose/features/patients/domain/entities/decision_status.dart';
import 'package:plastichoose/features/patients/domain/entities/patient.dart';
import 'package:plastichoose/features/patients/domain/repositories/patients_repository.dart';

/// Local storage implementation of PatientsRepository.
final class PatientsRepositoryImpl implements PatientsRepository {
  static const String _patientsKey = 'patients';

  /// Copies image files to app directory and returns new paths.
  Future<List<String>> _copyImagesToAppDirectory(
    List<String> imagePaths,
  ) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory imagesDir = Directory('${appDir.path}/patient_images');

    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final List<String> copiedPaths = <String>[];

    for (final String originalPath in imagePaths) {
      final File originalFile = File(originalPath);
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${originalFile.path.split('/').last}';
      final String newPath = '${imagesDir.path}/$fileName';

      await originalFile.copy(newPath);
      copiedPaths.add(newPath);
    }

    return copiedPaths;
  }

  @override
  Future<Result<Patient>> addPatient({
    required String name,
    required List<String> imagePaths,
  }) async {
    try {
      // Copy images to app directory
      final List<String> copiedImagePaths = await _copyImagesToAppDirectory(
        imagePaths,
      );

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String> existingPatientsJson =
          prefs.getStringList(_patientsKey) ?? [];

      final List<Patient> existingPatients = existingPatientsJson
          .map((json) => Patient.fromJson(jsonDecode(json)))
          .toList();

      final Patient newPatient = Patient(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        images: copiedImagePaths,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      existingPatients.add(newPatient);

      final List<String> updatedPatientsJson = existingPatients
          .map((patient) => jsonEncode(patient.toJson()))
          .toList();

      await prefs.setStringList(_patientsKey, updatedPatientsJson);

      return Ok(newPatient);
    } catch (e) {
      return Err(ValidationFailure('Hasta eklenirken hata oluştu: $e'));
    }
  }

  @override
  Future<Result<void>> deletePatient({required String patientId}) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String> existingPatientsJson =
          prefs.getStringList(_patientsKey) ?? [];

      final List<Patient> existingPatients = existingPatientsJson
          .map((json) => Patient.fromJson(jsonDecode(json)))
          .toList();

      // Find patient to delete and remove their images
      final Patient patientToDelete = existingPatients.firstWhere(
        (patient) => patient.id == patientId,
        orElse: () => throw Exception('Hasta bulunamadı'),
      );

      // Delete image files
      for (final String imagePath in patientToDelete.images) {
        final File imageFile = File(imagePath);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      }

      existingPatients.removeWhere((patient) => patient.id == patientId);

      final List<String> updatedPatientsJson = existingPatients
          .map((patient) => jsonEncode(patient.toJson()))
          .toList();

      await prefs.setStringList(_patientsKey, updatedPatientsJson);

      return const Ok(null);
    } catch (e) {
      return Err(ValidationFailure('Hasta silinirken hata oluştu: $e'));
    }
  }

  @override
  Future<Result<Patient>> updatePatient({required Patient patient}) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String> existingPatientsJson =
          prefs.getStringList(_patientsKey) ?? [];

      final List<Patient> existingPatients = existingPatientsJson
          .map((json) => Patient.fromJson(jsonDecode(json)))
          .toList();

      final int index = existingPatients.indexWhere((p) => p.id == patient.id);
      if (index == -1) {
        return Err(ValidationFailure('Hasta bulunamadı'));
      }

      final Patient oldPatient = existingPatients[index];

      // Delete only images that were removed (content-based diff instead of
      // list identity). This avoids deleting still-used image files.
      final Set<String> oldSet = Set<String>.from(oldPatient.images);
      final Set<String> newSet = Set<String>.from(patient.images);
      final Iterable<String> removed = oldSet.difference(newSet);
      for (final String path in removed) {
        final File f = File(path);
        if (await f.exists()) {
          await f.delete();
        }
      }

      final Patient updatedPatient = patient.copyWith(
        updatedAt: DateTime.now(),
      );
      existingPatients[index] = updatedPatient;

      final List<String> updatedPatientsJson = existingPatients
          .map((p) => jsonEncode(p.toJson()))
          .toList();

      await prefs.setStringList(_patientsKey, updatedPatientsJson);

      return Ok(updatedPatient);
    } catch (e) {
      return Err(ValidationFailure('Hasta güncellenirken hata oluştu: $e'));
    }
  }

  @override
  Future<Result<List<Patient>>> listPatients({
    String? nameQuery,
    DecisionStatus? status,
  }) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String> patientsJson = prefs.getStringList(_patientsKey) ?? [];

      List<Patient> patients = patientsJson
          .map((json) => Patient.fromJson(jsonDecode(json)))
          .toList();

      // Apply filters
      if (nameQuery != null && nameQuery.isNotEmpty) {
        patients = patients
            .where(
              (patient) =>
                  patient.name.toLowerCase().contains(nameQuery.toLowerCase()),
            )
            .toList();
      }

      if (status != null) {
        patients = patients
            .where((patient) => patient.decisionStatus == status)
            .toList();
      }

      // Sort by creation date (newest first)
      patients.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return Ok(patients);
    } catch (e) {
      return Err(ValidationFailure('Hastalar listelenirken hata oluştu: $e'));
    }
  }

  @override
  Future<Result<Patient>> getPatient({required String patientId}) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String> patientsJson = prefs.getStringList(_patientsKey) ?? [];

      final List<Patient> patients = patientsJson
          .map((json) => Patient.fromJson(jsonDecode(json)))
          .toList();

      final Patient patient = patients.firstWhere(
        (p) => p.id == patientId,
        orElse: () => throw Exception('Hasta bulunamadı'),
      );

      return Ok(patient);
    } catch (e) {
      return Err(ValidationFailure('Hasta bulunamadı: $e'));
    }
  }

  @override
  Future<Result<Patient>> decidePatient({
    required String patientId,
    required DecisionStatus decision,
    required DateTime decidedAt,
  }) async {
    try {
      final Result<Patient> getResult = await getPatient(patientId: patientId);

      return getResult.when(
        ok: (patient) async {
          final Patient updatedPatient = patient.copyWith(
            decisionStatus: decision,
            decisionAt: decidedAt,
          );

          return await updatePatient(patient: updatedPatient);
        },
        err: (failure) => Err(failure),
      );
    } catch (e) {
      return Err(ValidationFailure('Karar verilirken hata oluştu: $e'));
    }
  }

  @override
  Future<Result<Patient>> undoDecision({required String patientId}) async {
    try {
      final Result<Patient> getResult = await getPatient(patientId: patientId);

      return getResult.when(
        ok: (patient) async {
          final Patient updatedPatient = patient.copyWith(
            decisionStatus: DecisionStatus.none,
            decisionAt: null,
          );

          return await updatePatient(patient: updatedPatient);
        },
        err: (failure) => Err(failure),
      );
    } catch (e) {
      return Err(ValidationFailure('Karar geri alınırken hata oluştu: $e'));
    }
  }
}

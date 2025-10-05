import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plastichoose/app/di.dart';
import 'package:plastichoose/features/patients/domain/usecases/patient_usecases.dart';

final class AddPatientController extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final List<File> selectedImages = <File>[];
  bool isSaving = false;
  String? errorMessage;

  final ImagePicker _picker = ImagePicker();
  final AddPatient _addPatient = getIt<AddPatient>();

  Future<void> pickImages() async {
    errorMessage = null;
    try {
      final List<XFile> files = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      for (final XFile file in files) {
        if (selectedImages.length >= 50) break;
        selectedImages.add(File(file.path));
      }
      notifyListeners();
    } catch (e) {
      errorMessage = 'Görseller seçilirken hata oluştu: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> pickFromCamera() async {
    errorMessage = null;
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (file != null) {
        selectedImages.add(File(file.path));
        notifyListeners();
      }
    } catch (e) {
      errorMessage = 'Kameradan görsel alınırken hata oluştu: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> save(VoidCallback onSuccess) async {
    if (nameController.text.trim().isEmpty) {
      errorMessage = 'Hasta adı zorunludur';
      notifyListeners();
      return;
    }

    if (selectedImages.isEmpty) {
      errorMessage = 'En az bir görsel seçmelisiniz';
      notifyListeners();
      return;
    }

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      final List<String> imagePaths = selectedImages
          .map((file) => file.path)
          .toList();

      final result = await _addPatient.execute(
        AddPatientParams(
          name: nameController.text.trim(),
          imagePaths: imagePaths,
        ),
      );

      result.when(
        ok: (patient) {
          // Clear form
          nameController.clear();
          selectedImages.clear();
          onSuccess();
        },
        err: (failure) {
          errorMessage = failure.message;
        },
      );
    } catch (e) {
      errorMessage = 'Kayıt sırasında hata oluştu: $e';
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  void removeImageAt(int index) {
    if (index < 0 || index >= selectedImages.length) return;
    selectedImages.removeAt(index);
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}

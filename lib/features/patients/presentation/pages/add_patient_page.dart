import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:plastichoose/features/patients/presentation/controllers/add_patient_controller.dart';
import 'package:plastichoose/core/widgets/gradient_button.dart';
import 'package:plastichoose/core/widgets/labeled_text_field.dart';
import 'package:plastichoose/core/widgets/error_banner.dart';
import 'package:plastichoose/core/constants/app_constants.dart';

final class AddPatientPage extends StatelessWidget {
  const AddPatientPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color secondary = Theme.of(context).colorScheme.secondary;
    final Color tertiary = Theme.of(context).colorScheme.tertiary;

    return ChangeNotifierProvider<AddPatientController>(
      create: (_) => AddPatientController(),
      child: Builder(
        builder: (context) {
          final controller = context.watch<AddPatientController>();

          Future<void> pickImages() async {
            controller.pickImages();
          }

          Future<void> pickFromCamera() async {
            controller.pickFromCamera();
          }

          Future<void> savePatient() async {
            controller.save(() {
              Navigator.of(context).pop();
            });
          }

          void _showAnimatedImageDialog(
            BuildContext dialogContext,
            File imageFile,
          ) {
            showGeneralDialog(
              context: dialogContext,
              barrierDismissible: true,
              barrierLabel: '',
              barrierColor: Colors.black.withOpacity(0.8),
              transitionDuration: const Duration(milliseconds: 300),
              pageBuilder: (context, animation, secondaryAnimation) {
                return Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                      maxHeight: MediaQuery.of(context).size.height * 0.8,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(imageFile, fit: BoxFit.contain),
                    ),
                  ),
                );
              },
              transitionBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return ScaleTransition(
                      scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutBack,
                        ),
                      ),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
            );
          }

          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: const Text('Yeni Hasta'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: Colors.grey.shade800,
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Colors.white,
                    secondary.withOpacity(0.05),
                    tertiary.withOpacity(0.05),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (controller.errorMessage != null)
                        ErrorBanner(
                          message: controller.errorMessage!,
                          onClose: controller.clearError,
                        ),
                      LabeledTextField(
                        controller: controller.nameController,
                        label: 'Ad Soyad',
                        hint: 'Hastanın adı',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: GradientButton(
                              colors: [secondary, tertiary],
                              onPressed: pickImages,
                              child: const Text(
                                'Galeriden Seç',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GradientButton(
                              colors: [tertiary, secondary],
                              onPressed: pickFromCamera,
                              child: const Text(
                                'Kamera',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Görseller (${controller.selectedImages.length}/${AppConstants.maxImagesPerPatient})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1,
                              ),
                          itemCount: controller.selectedImages.length,
                          itemBuilder: (context, index) {
                            final File file = controller.selectedImages[index];
                            return Dismissible(
                              key: ValueKey(file.path),
                              background: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                              direction: DismissDirection.endToStart,
                              onDismissed: (_) =>
                                  controller.removeImageAt(index),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    children: [
                                      GestureDetector(
                                        onTap: () => _showAnimatedImageDialog(
                                          context,
                                          file,
                                        ),
                                        child: Image.file(
                                          file,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        left: 4,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(
                                              0.6,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      GradientButton(
                        colors:
                            controller.selectedImages.isNotEmpty &&
                                !controller.isSaving
                            ? [secondary, tertiary]
                            : [
                                secondary.withOpacity(0.3),
                                tertiary.withOpacity(0.3),
                              ],
                        onPressed:
                            controller.selectedImages.isNotEmpty &&
                                !controller.isSaving
                            ? savePatient
                            : null,
                        child: controller.isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Kaydet',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

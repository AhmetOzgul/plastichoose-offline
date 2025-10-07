import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plastichoose/features/patients/presentation/controllers/patient_list_controller.dart';
import 'package:plastichoose/features/patients/presentation/widgets/patient_card.dart';
import 'package:plastichoose/core/widgets/error_banner.dart';
import 'package:plastichoose/features/patients/presentation/widgets/empty_state_widget.dart';
import 'package:plastichoose/features/patients/presentation/widgets/status_change_dialog.dart';
import 'package:plastichoose/features/patients/presentation/widgets/delete_patient_dialog.dart';
import 'package:plastichoose/features/patients/presentation/pages/patient_details_page.dart';
import 'package:plastichoose/features/patients/domain/entities/patient.dart';

final class PatientListPage extends StatelessWidget {
  const PatientListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PatientListController>(
      create: (_) => PatientListController()..refresh(),
      child: const _PatientListPageContent(),
    );
  }
}

final class _PatientListPageContent extends StatelessWidget {
  const _PatientListPageContent();

  @override
  Widget build(BuildContext context) {
    final Color secondary = Theme.of(context).colorScheme.secondary;
    final Color tertiary = Theme.of(context).colorScheme.tertiary;

    return Scaffold(
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
          child: Column(
            children: <Widget>[
              _buildHeader(context),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Consumer<PatientListController>(
                    builder: (context, controller, child) {
                      if (controller.errorMessage != null) {
                        return Column(
                          children: <Widget>[
                            ErrorBanner(
                              message: controller.errorMessage!,
                              onClose: controller.clearError,
                            ),
                            Expanded(
                              child: controller.isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : controller.patients.isEmpty
                                  ? const EmptyStateWidget()
                                  : _buildPatientList(context, controller),
                            ),
                          ],
                        );
                      }

                      if (controller.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (controller.patients.isEmpty) {
                        return const EmptyStateWidget();
                      }

                      return _buildPatientList(context, controller);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back_ios, color: Colors.grey.shade700),
          ),
          const SizedBox(width: 8),
          Text(
            'Hasta Listesi',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const Spacer(),
          Consumer<PatientListController>(
            builder: (context, controller, child) {
              return Text(
                '${controller.patients.length} hasta',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPatientList(
    BuildContext context,
    PatientListController controller,
  ) {
    final Color secondary = Theme.of(context).colorScheme.secondary;
    final Color tertiary = Theme.of(context).colorScheme.tertiary;

    return ListView.builder(
      itemCount: controller.patients.length,
      itemBuilder: (context, index) {
        final patient = controller.patients[index];
        return PatientCard(
          patient: patient,
          secondary: secondary,
          tertiary: tertiary,
          onTap: () => _showPatientDetails(context, patient),
          onStatusChange: () => _showStatusChangeDialog(context, patient),
          onDelete: () => _showDeleteDialog(context, patient),
        );
      },
    );
  }

  void _showPatientDetails(BuildContext context, Patient patient) {
    final PatientListController controller = context
        .read<PatientListController>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => PatientDetailsPage(
          patient: patient,
          onPatientDeleted: () => controller.refresh(),
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _showStatusChangeDialog(BuildContext context, Patient patient) {
    final controller = context.read<PatientListController>();

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => StatusChangeDialog(
        patient: patient,
        onStatusChanged: (patientId, status) {
          controller.changePatientStatus(patientId, status);
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Patient patient) {
    final controller = context.read<PatientListController>();

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => DeletePatientDialog(
        patient: patient,
        onConfirm: () {
          controller.deletePatient(patient.id);
        },
      ),
    );
  }
}

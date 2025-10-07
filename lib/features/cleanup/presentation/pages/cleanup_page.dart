import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plastichoose/app/di.dart';
import 'package:plastichoose/features/cleanup/presentation/controllers/cleanup_controller.dart';
import 'package:plastichoose/features/patients/domain/usecases/patient_usecases.dart';
import 'package:plastichoose/features/cleanup/presentation/widgets/cleanup_warning_card.dart';
import 'package:plastichoose/core/widgets/date_range_selector.dart';
import 'package:plastichoose/features/cleanup/presentation/widgets/cleanup_options.dart';
import 'package:plastichoose/features/cleanup/presentation/widgets/cleanup_preview.dart';
import 'package:plastichoose/features/cleanup/presentation/widgets/cleanup_actions.dart';

final class CleanupPage extends StatelessWidget {
  const CleanupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CleanupController>(
      create: (_) => CleanupController(
        listPatients: getIt<ListPatients>(),
        deletePatient: getIt<DeletePatient>(),
      )..refreshPreview(),
      child: const _CleanupPageContent(),
    );
  }
}

final class _CleanupPageContent extends StatelessWidget {
  const _CleanupPageContent();

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
                  padding: const EdgeInsets.all(20),
                  child: Consumer<CleanupController>(
                    builder:
                        (
                          BuildContext context,
                          CleanupController controller,
                          Widget? child,
                        ) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const CleanupWarningCard(),
                              const SizedBox(height: 24),
                              DateRangeSelector(
                                label: 'Tümü',
                                value: controller.range,
                                onChanged: (DateTimeRange? r) async {
                                  controller.setRange(r);
                                  await controller.refreshPreview();
                                },
                              ),
                              const SizedBox(height: 24),
                              CleanupOptions(controller: controller),
                              const Spacer(),
                              CleanupPreview(controller: controller),
                              const SizedBox(height: 16),
                              CleanupActions(
                                isEnabled: controller.selectedPatientsCount > 0,
                                onDelete: () =>
                                    _handleDelete(context, controller),
                              ),
                            ],
                          );
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
            'Temizlik',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const Spacer(),
          Icon(Icons.cleaning_services, color: Colors.red.shade400, size: 24),
        ],
      ),
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    CleanupController controller,
  ) async {
    final bool? confirmed = await _showDeleteConfirmation(context, controller);
    if (confirmed == true) {
      await _showLoadingDialog(context, controller);
    }
  }

  Future<bool?> _showDeleteConfirmation(
    BuildContext context,
    CleanupController controller,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: <Widget>[
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red.shade600,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Onay Gerekli'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Bu işlem geri alınamaz!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.red.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Silinecek kayıtlar:',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text('• Tarih aralığı: ${controller.getDateRangeText()}'),
            Text('• Hasta sayısı: ${controller.selectedPatientsCount}'),
            Text(
              '• Karar verilmemiş hastalar: '
              '${controller.includeUndecided ? "Evet" : "Hayır"}',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.info_outline,
                    color: Colors.red.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tüm hasta fotoğrafları ve kayıtları kalıcı olarak silinecektir.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('İptal', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  Future<void> _showLoadingDialog(
    BuildContext context,
    CleanupController controller,
  ) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
            const SizedBox(height: 16),
            Text(
              'Hastalar siliniyor...',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Lütfen bekleyin',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );

    await controller.deleteSelected();

    if (context.mounted) {
      Navigator.of(context).pop();
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Seçili hastalar silindi'),
          backgroundColor: Colors.green.shade600,
        ),
      );
    }
  }
}

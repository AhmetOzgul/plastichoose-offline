import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plastichoose/app/di.dart';
import 'package:plastichoose/features/export/presentation/controllers/export_controller.dart';
import 'package:plastichoose/features/patients/domain/usecases/patient_usecases.dart';
import 'package:plastichoose/core/widgets/date_range_selector.dart';
import 'package:plastichoose/core/widgets/gradient_button.dart';

final class ExportPage extends StatelessWidget {
  const ExportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ExportController>(
      create: (_) =>
          ExportController(listPatients: getIt<ListPatients>())
            ..refreshPreview(),
      child: const _ExportPageContent(),
    );
  }
}

final class _ExportPageContent extends StatelessWidget {
  const _ExportPageContent();

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
                  child: Consumer<ExportController>(
                    builder:
                        (
                          BuildContext context,
                          ExportController controller,
                          Widget? child,
                        ) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _ExportIntroCard(),
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
                              _ExportOptions(controller: controller),
                              const SizedBox(height: 16),
                              _ExportFormatSelector(controller: controller),
                              const Spacer(),
                              _ExportPreview(controller: controller),
                              const SizedBox(height: 16),
                              _ExportActions(
                                isEnabled: controller.patientsCount > 0,
                                onExport: () =>
                                    _handleExport(context, controller),
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
            'Çıktı Alma',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const Spacer(),
          Icon(Icons.ios_share, color: Colors.blue.shade400, size: 24),
        ],
      ),
    );
  }

  Future<void> _handleExport(
    BuildContext context,
    ExportController controller,
  ) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const CircularProgressIndicator(strokeWidth: 3),
            const SizedBox(height: 16),
            Text(
              'Çıktı hazırlanıyor (${_formatLabel(controller.selectedFormat)})...',
            ),
            const SizedBox(height: 8),
            const Text('Lütfen bekleyin'),
          ],
        ),
      ),
    );
    String? savedPath;
    String? error;
    try {
      savedPath = await controller.generateAndSave(
        format: controller.selectedFormat,
      );
    } catch (e) {
      error = e.toString();
    }

    if (!context.mounted) return;
    Navigator.of(context).pop();

    if (error != null || savedPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Çıkış alınamadı: $error'),
          backgroundColor: Colors.red.shade600,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 4,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 4),
        content: Row(
          children: <Widget>[
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Dosya kaydedildi\n$savedPath',
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          backgroundColor: Colors.blue.shade600,
          label: 'Paylaş',
          textColor: Colors.white,
          onPressed: () => controller.shareFile(savedPath!),
        ),
      ),
    );
  }

  String _formatLabel(ExportFormat f) {
    switch (f) {
      case ExportFormat.excel:
        return 'Excel';
      case ExportFormat.txt:
        return 'TXT';
      case ExportFormat.word:
        return 'Word';
    }
  }
}

final class _ExportIntroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.info_outline, color: Colors.blue.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Veri Çıkışı',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Seçtiğiniz kriterlere göre hasta listesini Excel/Txt/Word formatında '
                  'indirebilir veya dışa aktarabilirsiniz.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.blue.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Date range selector moved to shared `DateRangeSelector` widget

final class _ExportOptions extends StatelessWidget {
  final ExportController controller;
  const _ExportOptions({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SwitchTile(
          title: 'Karar verilmemiş hastalar',
          value: controller.includeUndecided,
          onChanged: (bool v) => controller.toggleOption(undecided: v),
        ),
        _SwitchTile(
          title: 'Kabul edilen hastalar',
          value: controller.includeAccepted,
          onChanged: (bool v) => controller.toggleOption(accepted: v),
        ),
        _SwitchTile(
          title: 'Reddedilen hastalar',
          value: controller.includeRejected,
          onChanged: (bool v) => controller.toggleOption(rejected: v),
        ),
      ],
    );
  }
}

final class _ExportFormatSelector extends StatelessWidget {
  final ExportController controller;
  const _ExportFormatSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: SegmentedButton<ExportFormat>(
            segments: const <ButtonSegment<ExportFormat>>[
              ButtonSegment<ExportFormat>(
                value: ExportFormat.excel,
                label: Text('Excel'),
                icon: Icon(Icons.grid_on),
              ),
              ButtonSegment<ExportFormat>(
                value: ExportFormat.txt,
                label: Text('TXT'),
                icon: Icon(Icons.notes),
              ),
              ButtonSegment<ExportFormat>(
                value: ExportFormat.word,
                label: Text('Word'),
                icon: Icon(Icons.description),
              ),
            ],
            selected: <ExportFormat>{controller.selectedFormat},
            onSelectionChanged: (Set<ExportFormat> v) {
              if (v.isNotEmpty) controller.setFormat(v.first);
            },
          ),
        ),
      ],
    );
  }
}

final class _SwitchTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(title)),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

final class _ExportPreview extends StatelessWidget {
  final ExportController controller;
  const _ExportPreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.insert_drive_file, color: Colors.blue.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${controller.patientsCount} hasta seçildi',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

final class _ExportActions extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onExport;
  const _ExportActions({required this.isEnabled, required this.onExport});

  @override
  Widget build(BuildContext context) {
    final Color secondary = Theme.of(context).colorScheme.secondary;
    final Color tertiary = Theme.of(context).colorScheme.tertiary;
    final List<Color> colors = isEnabled
        ? <Color>[secondary, tertiary]
        : <Color>[secondary.withOpacity(0.3), tertiary.withOpacity(0.3)];
    return Row(
      children: <Widget>[
        Expanded(
          child: GradientButton(
            colors: colors,
            onPressed: isEnabled ? onExport : null,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.ios_share, color: Colors.white),
                SizedBox(width: 8),
                Text('Dışa Aktar', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

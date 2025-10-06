import 'dart:io';
import 'package:flutter/material.dart';
import 'package:plastichoose/features/patients/domain/entities/patient.dart';
import 'package:plastichoose/features/decision/presentation/widgets/full_screen_image_viewer.dart';
import 'package:plastichoose/features/patients/presentation/widgets/delete_patient_dialog.dart';
import 'package:plastichoose/app/di.dart';
import 'package:plastichoose/features/patients/domain/usecases/patient_usecases.dart';

final class PatientDetailsPage extends StatefulWidget {
  final Patient patient;
  final VoidCallback? onPatientDeleted;

  const PatientDetailsPage({
    super.key,
    required this.patient,
    this.onPatientDeleted,
  });

  @override
  State<PatientDetailsPage> createState() => _PatientDetailsPageState();
}

final class _PatientDetailsPageState extends State<PatientDetailsPage> {
  final DeletePatient _deletePatient = getIt<DeletePatient>();
  bool _isDeleting = false;

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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildPatientInfoCard(context),
                      const SizedBox(height: 20),
                      _buildImagesSection(context),
                    ],
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
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back_ios, color: Colors.grey.shade700),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.patient.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          IconButton(
            onPressed: _isDeleting ? null : () => _showDeleteDialog(context),
            icon: _isDeleting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.red.shade400,
                      ),
                    ),
                  )
                : Icon(
                    Icons.delete_rounded,
                    color: Colors.red.shade400,
                    size: 24,
                  ),
            tooltip: 'Hastayı Sil',
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInfoCard(BuildContext context) {
    final Color secondary = Theme.of(context).colorScheme.secondary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: secondary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Hasta Bilgileri',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          InfoRow(
            icon: Icons.person,
            label: 'Ad Soyad',
            value: widget.patient.name,
          ),
          const SizedBox(height: 12),
          InfoRow(
            icon: Icons.photo_library,
            label: 'Fotoğraf Sayısı',
            value: '${widget.patient.images.length} fotoğraf',
          ),
          const SizedBox(height: 12),
          InfoRow(
            icon: Icons.access_time,
            label: 'Kayıt Tarihi',
            value: _formatFullDate(widget.patient.createdAt),
          ),
          if (widget.patient.decisionAt != null) ...[
            const SizedBox(height: 12),
            InfoRow(
              icon: Icons.check_circle,
              label: 'Karar Tarihi',
              value: _formatFullDate(widget.patient.decisionAt!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImagesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Fotoğraflar',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        if (widget.patient.images.isEmpty)
          _buildEmptyImagesState(context)
        else
          _buildImagesGrid(context),
      ],
    );
  }

  Widget _buildEmptyImagesState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Fotoğraf Bulunamadı',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: widget.patient.images.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () => _showFullScreenImage(context, index),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(widget.patient.images[index]),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade100,
                  child: const Center(
                    child: Icon(Icons.error_outline, color: Colors.red),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFullScreenImage(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => FullScreenImageViewer(
          patient: widget.patient,
          initialIndex: initialIndex,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => DeletePatientDialog(
        patient: widget.patient,
        onConfirm: () async {
          setState(() {
            _isDeleting = true;
          });

          try {
            final result = await _deletePatient.execute(
              DeletePatientParams(patientId: widget.patient.id),
            );

            result.when(
              ok: (_) {
                // Önce dialogu kapat
                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop();
                }
                // Listeyi yenileme talebini, sayfa hala mounted iken bildir
                widget.onPatientDeleted?.call();
                // En son detay sayfasını kapat
                if (mounted && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              err: (failure) {
                if (mounted) {
                  setState(() {
                    _isDeleting = false;
                  });
                }
                // Hata mesajı göster
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(failure.message),
                      backgroundColor: Colors.red.shade600,
                    ),
                  );
                }
              },
            );
          } catch (e) {
            if (mounted) {
              setState(() {
                _isDeleting = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Hasta silinirken hata oluştu: $e'),
                  backgroundColor: Colors.red.shade600,
                ),
              );
            }
          }
        },
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

final class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:plastichoose/features/patients/domain/entities/patient.dart';
import 'package:plastichoose/features/decision/presentation/widgets/full_screen_image_viewer.dart';

final class ReviewCardGallery extends StatefulWidget {
  final Patient patient;
  final Color tertiary;

  const ReviewCardGallery({
    super.key,
    required this.patient,
    required this.tertiary,
  });

  @override
  State<ReviewCardGallery> createState() => _ReviewCardGalleryState();
}

final class _ReviewCardGalleryState extends State<ReviewCardGallery> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didUpdateWidget(covariant ReviewCardGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.patient.id != widget.patient.id) {
      // Hasta değiştiğinde galeriyi başa al
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      } else {
        _pageController = PageController(initialPage: 0);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.patient.images.isEmpty) {
      return _buildEmptyState();
    }
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.patient.images.length,
      itemBuilder: (context, index) {
        final String imagePath = widget.patient.images[index];
        return GestureDetector(
          onTap: () => _showFullScreenImage(index),
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: widget.tertiary.withOpacity(0.1),
                  child: const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Fotoğraf Bulunamadı',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bu hastaya ait fotoğraf bulunmuyor',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(int initialIndex) {
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
}

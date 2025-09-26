import 'package:flutter/material.dart';
import 'package:plastichoose/features/patients/domain/entities/patient.dart';
import 'package:plastichoose/features/patients/domain/entities/decision_status.dart';
import 'package:plastichoose/features/decision/presentation/widgets/review_card_header.dart';
import 'package:plastichoose/features/decision/presentation/widgets/review_card_gallery.dart';
import 'package:plastichoose/features/decision/presentation/widgets/review_card_actions.dart';
import 'package:plastichoose/features/decision/presentation/widgets/swipe_feedback_overlay.dart';

final class ModernReviewCard extends StatefulWidget {
  final Patient patient;
  final void Function(Patient, DecisionStatus) onDecision;
  final Color secondary;
  final Color tertiary;

  const ModernReviewCard({
    super.key,
    required this.patient,
    required this.onDecision,
    required this.secondary,
    required this.tertiary,
  });

  @override
  State<ModernReviewCard> createState() => _ModernReviewCardState();
}

final class _ModernReviewCardState extends State<ModernReviewCard>
    with TickerProviderStateMixin {
  late AnimationController _swipeAnimationController;
  late AnimationController _scaleAnimationController;
  late AnimationController _slideInController;

  double _dragOffset = 0;
  bool _isDragging = false;
  String? _swipeDirection;

  @override
  void initState() {
    super.initState();
    _swipeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _slideInController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
  }

  @override
  void didUpdateWidget(ModernReviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.patient.id != widget.patient.id) {
      _resetCardPosition();
      _slideInController
        ..reset()
        ..forward();
    }
  }

  void _resetCardPosition() {
    setState(() {
      _dragOffset = 0;
      _swipeDirection = null;
      _isDragging = false;
    });
    _swipeAnimationController.reset();
    _scaleAnimationController.reset();
  }

  @override
  void dispose() {
    _swipeAnimationController.dispose();
    _scaleAnimationController.dispose();
    _slideInController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _swipeAnimationController,
          _slideInController,
        ]),
        builder: (context, child) {
          final double slideOffset = (1.0 - _slideInController.value) * 300;
          return Transform.translate(
            offset: Offset(_dragOffset + slideOffset, 0),
            child: Transform.scale(
              scale: 1.0 - (_dragOffset.abs() / 1000),
              child: Stack(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: widget.secondary.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: <Widget>[
                        ReviewCardHeader(
                          patient: widget.patient,
                          secondary: widget.secondary,
                        ),
                        Expanded(
                          child: ReviewCardGallery(
                            patient: widget.patient,
                            tertiary: widget.tertiary,
                          ),
                        ),
                        ReviewCardActions(
                          onAccept: () => _handleAccept(),
                          onReject: () => _handleReject(),
                          onSkip: () => _handleSkip(),
                        ),
                      ],
                    ),
                  ),
                  if (_isDragging && _swipeDirection != null)
                    SwipeFeedbackOverlay(
                      direction: _swipeDirection!,
                      dragOffset: _dragOffset,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    _isDragging = true;
    _scaleAnimationController.forward();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    setState(() {
      _dragOffset += details.delta.dx;
      if (_dragOffset > 20) {
        _swipeDirection = 'right';
      } else if (_dragOffset < -20) {
        _swipeDirection = 'left';
      } else {
        _swipeDirection = null;
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _isDragging = false;
    _scaleAnimationController.reverse();
    const double threshold = 100.0;
    if (_dragOffset > threshold) {
      _handleAccept();
    } else if (_dragOffset < -threshold) {
      _handleReject();
    } else {
      _resetCard();
    }
  }

  void _resetCard() {
    _swipeAnimationController.forward().then((_) {
      setState(() {
        _dragOffset = 0;
        _swipeDirection = null;
      });
      _swipeAnimationController.reset();
    });
  }

  void _handleAccept() {
    _animateCardOut('right', () {
      widget.onDecision(widget.patient, DecisionStatus.accepted);
    });
  }

  void _handleReject() {
    _animateCardOut('left', () {
      widget.onDecision(widget.patient, DecisionStatus.rejected);
    });
  }

  void _handleSkip() {
    _animateCardOut('bottom', () {});
  }

  void _animateCardOut(String direction, VoidCallback onComplete) {
    final double targetOffset = direction == 'right'
        ? MediaQuery.of(context).size.width
        : direction == 'left'
        ? -MediaQuery.of(context).size.width
        : 0;
    _swipeAnimationController.forward().then((_) {
      setState(() {
        _dragOffset = targetOffset.toDouble();
      });
      Future.delayed(const Duration(milliseconds: 200), onComplete);
    });
  }
}
